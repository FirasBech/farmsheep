const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ─────────────────────────────────────────────────────────────────────────────
// AI Provider configuration
//
// Set via Firebase CLI before deploying:
//   firebase functions:config:set \
//     ai.provider="groq" \
//     ai.fallback="anthropic" \
//     ai.groq_key="gsk_..." \
//     ai.deepseek_key="sk-..." \
//     ai.mistral_key="..." \
//     ai.openai_key="sk-..." \
//     ai.openrouter_key="sk-or-..." \
//     ai.anthropic_key="sk-ant-..."
//
// Supported providers and their free/cheap tiers:
//   groq        → Llama-3.3-70B  — FREE 200M tokens/month
//   deepseek    → DeepSeek-Chat  — $0.14/M input (1M context)
//   mistral     → Mistral-Small  — $0.10/M (1B tokens/month free tier)
//   openai      → GPT-4o-mini    — $0.15/M
//   openrouter  → configurable   — meta-router, 60+ free models
//   anthropic   → Claude Sonnet  — $3/M (legacy, kept for fallback)
// ─────────────────────────────────────────────────────────────────────────────

const OPENAI_COMPATIBLE_PROVIDERS = {
  groq: {
    baseURL: 'https://api.groq.com/openai/v1',
    model: 'llama-3.3-70b-versatile',
    keyField: 'groq_key',
  },
  deepseek: {
    baseURL: 'https://api.deepseek.com',
    model: 'deepseek-chat',
    keyField: 'deepseek_key',
  },
  mistral: {
    baseURL: 'https://api.mistral.ai/v1',
    model: 'mistral-small-latest',
    keyField: 'mistral_key',
  },
  openai: {
    baseURL: 'https://api.openai.com/v1',
    model: 'gpt-4o-mini',
    keyField: 'openai_key',
  },
  openrouter: {
    baseURL: 'https://openrouter.ai/api/v1',
    model: 'openai/gpt-4o-mini',
    keyField: 'openrouter_key',
  },
};

// Farm-domain prompt templates. Each returns a string given the payload.
const PROMPTS = {
  healthChat: (p) =>
    `You are a concise veterinary assistant for a sheep/goat farm. Answer practically in 2-4 sentences.
Animal: ${p.animalType}, breed ${p.breed}, age ${p.ageMonths} months, current status: ${p.status}.
Recent health events: ${JSON.stringify(p.recentHealthLogs || [])}.
Farmer's question: ${p.question}`,

  healthPrediction: (p) =>
    `You are a livestock health expert. Analyze this animal's history and list 3-5 specific health risks ranked by likelihood. Use bullet points.
Animal: ${p.animalType}, breed ${p.breed}, age ${p.ageMonths} months, status: ${p.currentStatus}.
Health log history: ${JSON.stringify(p.healthLogs || [])}.
Pregnancy history: ${JSON.stringify(p.pregnancyHistory || [])}.`,

  logSuggestion: (p) =>
    `You are a farm management assistant. Based on this animal's recent activity, suggest the most appropriate log entry.
Animal: ${p.animalType}, breed ${p.breed}, current status: ${p.currentStatus}.
Recent activities (days ago): ${JSON.stringify(p.recentLogs || [])}.
Return ONLY a valid JSON object with no extra text: {"type": "...", "notes": "..."}
Valid type values: Vaccination, Treatment, Birth, Feeding, Observation, Health Check, Other`,

  herdSummary: (p) =>
    `You are an agricultural analyst. Write exactly 3 plain-language sentences summarizing this farm's current status and any noteworthy observations.
Farm: "${p.farmName}", ${p.totalAnimals} animals total.
Status breakdown: ${JSON.stringify(p.statusBreakdown || {})}.
Breeds: ${(p.breeds || []).join(', ')}.
Recent activity types: ${(p.recentLogTypes || []).join(', ')}.`,

  breedRecommendation: (p) =>
    `You are a livestock breed specialist. Recommend exactly 3 sheep or goat breeds for this context. For each: name, why it fits (1 sentence), one key care tip.
Climate: ${p.climate}.
Purpose: ${p.purpose}.
Farmer preferences: ${p.preferences || 'none specified'}.`,
};

/**
 * Calls an OpenAI-compatible provider (Groq, DeepSeek, Mistral, OpenAI, OpenRouter).
 */
async function callOpenAiCompatible(providerName, prompt, config) {
  const spec = OPENAI_COMPATIBLE_PROVIDERS[providerName];
  const apiKey = config.ai && config.ai[spec.keyField];
  if (!apiKey) {
    throw new Error(
      `API key not set for provider "${providerName}". ` +
      `Run: firebase functions:config:set ai.${spec.keyField}="YOUR_KEY"`
    );
  }
  const { default: OpenAI } = require('openai');
  const client = new OpenAI({ apiKey, baseURL: spec.baseURL });
  const completion = await client.chat.completions.create({
    model: spec.model,
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1024,
    temperature: 0.7,
  });
  return {
    response: completion.choices[0].message.content,
    provider: providerName,
    model: spec.model,
  };
}

/**
 * Calls Anthropic Claude directly using the Anthropic SDK.
 */
async function callAnthropic(prompt, config) {
  // Support both new ai.anthropic_key and legacy anthropic.key
  const apiKey = (config.ai && config.ai.anthropic_key) ||
                 (config.anthropic && config.anthropic.key);
  if (!apiKey) {
    throw new Error(
      'Anthropic API key not set. ' +
      'Run: firebase functions:config:set ai.anthropic_key="sk-ant-..."'
    );
  }
  const Anthropic = require('@anthropic-ai/sdk');
  const client = new Anthropic.default({ apiKey });
  const model = 'claude-sonnet-4-6';
  const message = await client.messages.create({
    model,
    max_tokens: 1024,
    messages: [{ role: 'user', content: prompt }],
  });
  return {
    response: message.content[0].text,
    provider: 'anthropic',
    model,
  };
}

/**
 * Dispatches to the correct provider implementation.
 */
async function callProvider(providerName, prompt, config) {
  if (providerName in OPENAI_COMPATIBLE_PROVIDERS) {
    return callOpenAiCompatible(providerName, prompt, config);
  }
  if (providerName === 'anthropic') {
    return callAnthropic(prompt, config);
  }
  throw new Error(
    `Unknown provider "${providerName}". ` +
    `Valid options: ${Object.keys(OPENAI_COMPATIBLE_PROVIDERS).join(', ')}, anthropic`
  );
}

/**
 * aiProxy — Auth-gated AI feature proxy supporting 6 providers with fallback.
 *
 * Accepts: { feature: string, payload: object }
 * Returns: { response: string, provider: string, model: string, usedFallback?: boolean }
 */
exports.aiProxy = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required.');
  }
  // App Check: reject calls not originating from a verified app build.
  // Enable enforcement in Firebase Console → App Check before activating this.
  if (context.app === undefined) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'App Check verification failed.'
    );
  }

  // Per-user rate limit: 20 calls per hour.
  const uid = context.auth.uid;
  const db = admin.firestore();
  const rateLimitRef = db.collection('aiRateLimit').doc(uid);
  const now = Date.now();
  const oneHour = 60 * 60 * 1000;
  await db.runTransaction(async (tx) => {
    const doc = await tx.get(rateLimitRef);
    const rdata = doc.data() || { count: 0, windowStart: now };
    if (now - rdata.windowStart > oneHour) {
      tx.set(rateLimitRef, { count: 1, windowStart: now });
    } else if (rdata.count >= 20) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'AI rate limit reached. Try again in an hour.'
      );
    } else {
      tx.set(rateLimitRef, { count: rdata.count + 1, windowStart: rdata.windowStart });
    }
  });

  const { feature, payload } = data;

  if (!PROMPTS[feature]) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Unknown AI feature: "${feature}". Valid features: ${Object.keys(PROMPTS).join(', ')}`
    );
  }

  const prompt = PROMPTS[feature](payload || {});
  const config = functions.config();
  const primaryProvider = (config.ai && config.ai.provider) || 'anthropic';
  const fallbackProvider = config.ai && config.ai.fallback;

  try {
    return await callProvider(primaryProvider, prompt, config);
  } catch (primaryError) {
    functions.logger.warn(
      `Primary provider "${primaryProvider}" failed: ${primaryError.message}`
    );

    if (fallbackProvider && fallbackProvider !== primaryProvider) {
      try {
        const result = await callProvider(fallbackProvider, prompt, config);
        functions.logger.info(
          `Fallback provider "${fallbackProvider}" succeeded.`
        );
        return { ...result, usedFallback: true };
      } catch (fallbackError) {
        throw new functions.https.HttpsError(
          'internal',
          `Both providers failed. ` +
          `Primary (${primaryProvider}): ${primaryError.message}. ` +
          `Fallback (${fallbackProvider}): ${fallbackError.message}`
        );
      }
    }

    throw new functions.https.HttpsError(
      'internal',
      `AI provider error (${primaryProvider}): ${primaryError.message}`
    );
  }
});

// Keep claudeProxy as an alias so existing deployments don't break immediately.
exports.claudeProxy = exports.aiProxy;

// ─────────────────────────────────────────────────────────────────────────────
// createPartner — Admin-only. Creates a partner account and links to farm.
// ─────────────────────────────────────────────────────────────────────────────
exports.createPartner = functions.https.onCall(async (data, context) => {
  const callerUid = context.auth && context.auth.uid;
  if (!callerUid) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }
  if (context.app === undefined) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'App Check verification failed.'
    );
  }
  if (context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Only admin users can create partners.');
  }

  const { email, password, farmId } = data;
  if (!email || !password) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and password are required.');
  }

  const db = admin.firestore();

  // Dedup: check if this email is already a partner in this farm.
  // Case (a) + (b): email already exists in Firebase Auth.
  let existingUser = null;
  try {
    existingUser = await admin.auth().getUserByEmail(email);
  } catch (err) {
    // auth/user-not-found — user doesn't exist yet, fall through to case (c).
    if (err.code !== 'auth/user-not-found') {
      throw new functions.https.HttpsError('internal', err.message);
    }
  }

  if (existingUser) {
    if (farmId) {
      const farmDoc = await db.collection('farms').doc(farmId).get();
      const partnerIds = farmDoc.exists ? (farmDoc.data().partnerIds || []) : [];
      if (partnerIds.includes(existingUser.uid)) {
        // Case (a): already in this farm.
        throw new functions.https.HttpsError(
          'already-exists',
          'This partner is already added to the farm.'
        );
      }
      // Case (b): user exists, not yet in this farm — link them.
      await admin.auth().setCustomUserClaims(existingUser.uid, {
        role: 'partner',
        circleAdmin: callerUid,
      });
      await db.collection('farms').doc(farmId).update({
        partnerIds: admin.firestore.FieldValue.arrayUnion([existingUser.uid]),
      });
      await db.collection('partners').doc(existingUser.uid).set(
        { email, circleAdmin: callerUid, createdAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );
      return { uid: existingUser.uid };
    }
    throw new functions.https.HttpsError('already-exists', 'A user with this email already exists.');
  }

  try {
    const userRecord = await admin.auth().createUser({ email, password });
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role: 'partner',
      circleAdmin: callerUid,
    });
    await db.collection('partners').doc(userRecord.uid).set({
      email,
      circleAdmin: callerUid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    if (farmId) {
      await db.collection('farms').doc(farmId).update({
        partnerIds: admin.firestore.FieldValue.arrayUnion([userRecord.uid]),
      });
    }
    return { uid: userRecord.uid };
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      throw new functions.https.HttpsError('already-exists', 'A user with this email already exists.');
    }
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// deleteFarmCascade — Cascade-deletes a farm and all its sub-documents.
// ─────────────────────────────────────────────────────────────────────────────
exports.deleteFarmCascade = functions.https.onCall(async (data, context) => {
  const callerUid = context.auth && context.auth.uid;
  if (!callerUid) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required.');
  }

  const { farmId } = data;
  if (!farmId) {
    throw new functions.https.HttpsError('invalid-argument', 'farmId is required.');
  }

  const db = admin.firestore();
  const farmDoc = await db.collection('farms').doc(farmId).get();
  if (!farmDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Farm not found.');
  }
  if (farmDoc.data().ownerId !== callerUid) {
    throw new functions.https.HttpsError('permission-denied', 'Only the farm owner can delete the farm.');
  }

  // Delete all animal photos from Storage before removing Firestore docs.
  const animalSnap = await db.collection('animals').where('farmId', '==', farmId).get();
  const bucket = admin.storage().bucket();
  const storageDeletes = [];
  for (const doc of animalSnap.docs) {
    const photoUrls = doc.data().photoUrls || [];
    for (const url of photoUrls) {
      const match = url.match(/\/o\/([^?]+)/);
      if (match) {
        const filePath = decodeURIComponent(match[1]);
        storageDeletes.push(bucket.file(filePath).delete().catch(() => {}));
      }
    }
  }
  await Promise.all(storageDeletes);

  // Batch-delete related documents in chunks of 500 (Firestore limit).
  const collections = ['animals', 'manualLogs', 'activityLogs'];
  for (const col of collections) {
    const snap = col === 'animals'
      ? animalSnap
      : await db.collection(col).where('farmId', '==', farmId).get();
    const batches = [];
    let batch = db.batch();
    let count = 0;
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
      count++;
      if (count === 500) {
        batches.push(batch.commit());
        batch = db.batch();
        count = 0;
      }
    }
    if (count > 0) batches.push(batch.commit());
    await Promise.all(batches);
  }

  await db.collection('farms').doc(farmId).delete();
  await db.collection('adminAudit').add({
    action: 'deleteFarm',
    farmId,
    performedBy: callerUid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});
