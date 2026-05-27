require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const admin = require('firebase-admin');

const app = express();
const PORT = process.env.PORT || 3000;
const SERVER_SECRET = process.env.SERVER_SECRET;
const SERVER_URL = process.env.SERVER_URL || `http://localhost:${PORT}`;

// ─── Uploads directory ────────────────────────────────────────────────────────
const UPLOADS_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(UPLOADS_DIR)) fs.mkdirSync(UPLOADS_DIR);

// ─── Firebase Admin ───────────────────────────────────────────────────────────
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './firebase-service-account.json';
let firebaseInitialized = false;
try {
  if (fs.existsSync(path.resolve(serviceAccountPath))) {
    const serviceAccount = require(path.resolve(serviceAccountPath));
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    firebaseInitialized = true;
    console.log('Firebase Admin: connected');
  } else {
    console.warn(`⚠️  Firebase service account not found at ${serviceAccountPath}`);
    console.warn('   Partner creation and farm cascade delete will not work.');
    console.warn('   Download from: Firebase Console → Project Settings → Service Accounts');
  }
} catch (err) {
  console.error('Firebase Admin init error:', err.message);
}

// ─── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use('/uploads', express.static(UPLOADS_DIR));

function requireAuth(req, res, next) {
  if (!SERVER_SECRET) return next(); // no secret set — open (dev mode only)
  const auth = req.headers.authorization || '';
  if (!auth.startsWith('Bearer ') || auth.slice(7) !== SERVER_SECRET) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

const multerStorage = multer.diskStorage({
  destination: UPLOADS_DIR,
  filename: (req, file, cb) => cb(null, `${uuidv4()}.jpg`),
});
const upload = multer({ storage: multerStorage, limits: { fileSize: 10 * 1024 * 1024 } });

// ─── Health ───────────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ ok: true, firebase: firebaseInitialized, time: new Date().toISOString() });
});

// ─────────────────────────────────────────────────────────────────────────────
// Photo storage
// ─────────────────────────────────────────────────────────────────────────────

app.post('/api/photo/upload', requireAuth, upload.single('photo'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const url = `${SERVER_URL}/uploads/${req.file.filename}`;
  res.json({ url });
});

app.delete('/api/photo', requireAuth, (req, res) => {
  const { url } = req.body;
  if (!url || typeof url !== 'string') {
    return res.status(400).json({ error: 'url is required' });
  }
  const match = url.match(/\/uploads\/([^/?#]+)$/);
  if (!match) return res.json({ success: true, skipped: true });
  const filePath = path.join(UPLOADS_DIR, match[1]);
  try {
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// AI proxy
// ─────────────────────────────────────────────────────────────────────────────

const OPENAI_COMPATIBLE_PROVIDERS = {
  groq:       { baseURL: 'https://api.groq.com/openai/v1',    model: 'llama-3.3-70b-versatile',  envKey: 'GROQ_API_KEY' },
  xai:        { baseURL: 'https://api.x.ai/v1',               model: 'grok-2-latest',             envKey: 'XAI_API_KEY' },
  deepseek:   { baseURL: 'https://api.deepseek.com',          model: 'deepseek-chat',             envKey: 'DEEPSEEK_API_KEY' },
  mistral:    { baseURL: 'https://api.mistral.ai/v1',         model: 'mistral-small-latest',      envKey: 'MISTRAL_API_KEY' },
  openai:     { baseURL: 'https://api.openai.com/v1',         model: 'gpt-4o-mini',               envKey: 'OPENAI_API_KEY' },
  openrouter: { baseURL: 'https://openrouter.ai/api/v1',      model: 'openai/gpt-4o-mini',        envKey: 'OPENROUTER_API_KEY' },
};

const PROMPTS = {
  healthChat: (p) =>
    `You are a concise veterinary assistant for a sheep/goat farm. Answer practically in 2-4 sentences.\nAnimal: ${p.animalType}, breed ${p.breed}, age ${p.ageMonths} months, current status: ${p.status}.\nRecent health events: ${JSON.stringify(p.recentHealthLogs || [])}.\nFarmer's question: ${p.question}`,

  healthPrediction: (p) =>
    `You are a livestock health expert. Analyze this animal's history and list 3-5 specific health risks ranked by likelihood. Use bullet points.\nAnimal: ${p.animalType}, breed ${p.breed}, age ${p.ageMonths} months, status: ${p.currentStatus}.\nHealth log history: ${JSON.stringify(p.healthLogs || [])}.\nPregnancy history: ${JSON.stringify(p.pregnancyHistory || [])}.`,

  logSuggestion: (p) =>
    `You are a farm management assistant. Based on this animal's recent activity, suggest the most appropriate log entry.\nAnimal: ${p.animalType}, breed ${p.breed}, current status: ${p.currentStatus}.\nRecent activities (days ago): ${JSON.stringify(p.recentLogs || [])}.\nReturn ONLY a valid JSON object with no extra text: {"type": "...", "notes": "..."}\nValid type values: Vaccination, Treatment, Birth, Feeding, Observation, Health Check, Other`,

  herdSummary: (p) =>
    `You are an agricultural analyst. Write exactly 3 plain-language sentences summarizing this farm's current status and any noteworthy observations.\nFarm: "${p.farmName}", ${p.totalAnimals} animals total.\nStatus breakdown: ${JSON.stringify(p.statusBreakdown || {})}.\nBreeds: ${(p.breeds || []).join(', ')}.\nRecent activity types: ${(p.recentLogTypes || []).join(', ')}.`,

  breedRecommendation: (p) =>
    `You are a livestock breed specialist. Recommend exactly 3 sheep or goat breeds for this context. For each: name, why it fits (1 sentence), one key care tip.\nClimate: ${p.climate}.\nPurpose: ${p.purpose}.\nFarmer preferences: ${p.preferences || 'none specified'}.`,
};

// In-memory rate limiting (uid → { count, windowStart }); resets on server restart
const rateLimits = new Map();
function checkRateLimit(uid) {
  const now = Date.now();
  const oneHour = 60 * 60 * 1000;
  const entry = rateLimits.get(uid) || { count: 0, windowStart: now };
  if (now - entry.windowStart > oneHour) {
    rateLimits.set(uid, { count: 1, windowStart: now });
    return true;
  }
  if (entry.count >= 20) return false;
  rateLimits.set(uid, { count: entry.count + 1, windowStart: entry.windowStart });
  return true;
}

async function callOpenAiCompatible(providerName, prompt) {
  const spec = OPENAI_COMPATIBLE_PROVIDERS[providerName];
  const apiKey = process.env[spec.envKey];
  if (!apiKey) throw new Error(`API key not set for provider "${providerName}". Set ${spec.envKey} in .env`);
  const { default: OpenAI } = require('openai');
  const client = new OpenAI({ apiKey, baseURL: spec.baseURL });
  const completion = await client.chat.completions.create({
    model: spec.model,
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1024,
    temperature: 0.7,
  });
  return { response: completion.choices[0].message.content, provider: providerName, model: spec.model };
}

async function callAnthropic(prompt) {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) throw new Error('ANTHROPIC_API_KEY not set in .env');
  const { default: Anthropic } = require('@anthropic-ai/sdk');
  const client = new Anthropic({ apiKey });
  const model = 'claude-sonnet-4-6';
  const message = await client.messages.create({
    model,
    max_tokens: 1024,
    messages: [{ role: 'user', content: prompt }],
  });
  return { response: message.content[0].text, provider: 'anthropic', model };
}

async function callProvider(providerName, prompt) {
  if (providerName in OPENAI_COMPATIBLE_PROVIDERS) return callOpenAiCompatible(providerName, prompt);
  if (providerName === 'anthropic') return callAnthropic(prompt);
  throw new Error(`Unknown provider "${providerName}". Valid: ${Object.keys(OPENAI_COMPATIBLE_PROVIDERS).join(', ')}, anthropic`);
}

app.post('/api/ai', requireAuth, async (req, res) => {
  const { feature, payload, uid } = req.body;
  if (!PROMPTS[feature]) {
    return res.status(400).json({ error: `Unknown AI feature: "${feature}". Valid: ${Object.keys(PROMPTS).join(', ')}` });
  }
  if (uid && !checkRateLimit(uid)) {
    return res.status(429).json({ error: 'AI rate limit reached (20/hour). Try again later.' });
  }
  const prompt = PROMPTS[feature](payload || {});
  const primaryProvider = process.env.AI_PROVIDER || 'groq';
  const fallbackProvider = process.env.AI_FALLBACK;
  try {
    const result = await callProvider(primaryProvider, prompt);
    res.json(result);
  } catch (primaryError) {
    console.warn(`Primary provider "${primaryProvider}" failed:`, primaryError.message);
    if (fallbackProvider && fallbackProvider !== primaryProvider) {
      try {
        const result = await callProvider(fallbackProvider, prompt);
        res.json({ ...result, usedFallback: true });
      } catch (fallbackError) {
        res.status(500).json({
          error: `Both providers failed. Primary (${primaryProvider}): ${primaryError.message}. Fallback (${fallbackProvider}): ${fallbackError.message}`,
        });
      }
    } else {
      res.status(500).json({ error: `AI provider error (${primaryProvider}): ${primaryError.message}` });
    }
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Partner management
// ─────────────────────────────────────────────────────────────────────────────

app.post('/api/partner', requireAuth, async (req, res) => {
  if (!firebaseInitialized) {
    return res.status(503).json({ error: 'Firebase Admin not initialized. Add firebase-service-account.json to the server folder.' });
  }
  const { email, password, farmId, callerUid } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'email and password are required' });

  const db = admin.firestore();
  let existingUser = null;
  try {
    existingUser = await admin.auth().getUserByEmail(email);
  } catch (err) {
    if (err.code !== 'auth/user-not-found') {
      return res.status(500).json({ error: err.message });
    }
  }

  if (existingUser) {
    if (farmId) {
      const farmDoc = await db.collection('farms').doc(farmId).get();
      const partnerIds = farmDoc.exists ? (farmDoc.data().partnerIds || []) : [];
      if (partnerIds.includes(existingUser.uid)) {
        return res.status(409).json({ error: 'already-in-farm', message: 'This partner is already added to the farm.' });
      }
      await admin.auth().setCustomUserClaims(existingUser.uid, { role: 'partner', circleAdmin: callerUid });
      await db.collection('farms').doc(farmId).update({
        partnerIds: admin.firestore.FieldValue.arrayUnion(existingUser.uid),
      });
      await db.collection('partners').doc(existingUser.uid).set(
        { email, circleAdmin: callerUid, createdAt: admin.firestore.FieldValue.serverTimestamp() },
        { merge: true },
      );
      return res.json({ uid: existingUser.uid });
    }
    return res.status(409).json({ error: 'already-exists', message: 'A user with this email already exists.' });
  }

  try {
    const userRecord = await admin.auth().createUser({ email, password });
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: 'partner', circleAdmin: callerUid });
    await db.collection('partners').doc(userRecord.uid).set({
      email,
      circleAdmin: callerUid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    if (farmId) {
      await db.collection('farms').doc(farmId).update({
        partnerIds: admin.firestore.FieldValue.arrayUnion(userRecord.uid),
      });
    }
    res.json({ uid: userRecord.uid });
  } catch (err) {
    if (err.code === 'auth/email-already-exists') {
      return res.status(409).json({ error: 'already-exists', message: 'A user with this email already exists.' });
    }
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Farm cascade delete
// ─────────────────────────────────────────────────────────────────────────────

app.post('/api/farm/delete-cascade', requireAuth, async (req, res) => {
  if (!firebaseInitialized) {
    return res.status(503).json({ error: 'Firebase Admin not initialized.' });
  }
  const { farmId, callerUid } = req.body;
  if (!farmId) return res.status(400).json({ error: 'farmId is required' });

  const db = admin.firestore();
  const farmDoc = await db.collection('farms').doc(farmId).get();
  if (!farmDoc.exists) return res.status(404).json({ error: 'Farm not found' });
  if (farmDoc.data().ownerId !== callerUid) {
    return res.status(403).json({ error: 'Only the farm owner can delete the farm.' });
  }

  const animalSnap = await db.collection('animals').where('farmId', '==', farmId).get();

  // Delete server-hosted photos
  for (const doc of animalSnap.docs) {
    const photoUrls = doc.data().photoUrls || [];
    for (const url of photoUrls) {
      const match = url.match(/\/uploads\/([^/?#]+)$/);
      if (match) {
        const filePath = path.join(UPLOADS_DIR, match[1]);
        try { if (fs.existsSync(filePath)) fs.unlinkSync(filePath); } catch (_) {}
      }
    }
  }

  // Batch-delete Firestore docs (500-doc chunks)
  for (const col of ['animals', 'manualLogs', 'activityLogs']) {
    const snap = col === 'animals' ? animalSnap : await db.collection(col).where('farmId', '==', farmId).get();
    const batches = [];
    let batch = db.batch();
    let count = 0;
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
      count++;
      if (count === 500) { batches.push(batch.commit()); batch = db.batch(); count = 0; }
    }
    if (count > 0) batches.push(batch.commit());
    await Promise.all(batches);
  }

  await db.collection('farms').doc(farmId).delete();
  res.json({ success: true });
});

// ─────────────────────────────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\nFarmSheep server running on port ${PORT}`);
  console.log(`Server URL: ${SERVER_URL}`);
  console.log(`Uploads:    ${UPLOADS_DIR}`);
  console.log(`AI provider: ${process.env.AI_PROVIDER || 'groq (default)'}\n`);
});
