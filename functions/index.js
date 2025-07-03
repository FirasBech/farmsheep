const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Callable function to create a partner user under the calling admin's circle.
 * Only users with custom claim { role: 'admin' } can invoke.
 * Expects: { email: string, password: string }
 * Returns: { uid: string }
 */
exports.createPartner = functions.https.onCall(async (data, context) => {
  // Authentication check
  const callerUid = context.auth?.uid;
  if (!callerUid) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  // Authorization: only admin can invoke
  const callerClaims = context.auth.token;
  if (callerClaims.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Only admin users can create partners.');
  }

  const { email, password } = data;
  if (!email || !password) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and password are required.');
  }

  try {
    // Create the new partner user
    const userRecord = await admin.auth().createUser({ email, password });

    // Assign custom claims: partner role and circle owner
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role: 'partner',
      circleAdmin: callerUid,
    });

    // Optionally record in Firestore for lookup
    const db = admin.firestore();
    await db.collection('partners').doc(userRecord.uid).set({
      email,
      circleAdmin: callerUid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { uid: userRecord.uid };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
