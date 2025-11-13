const admin = require('firebase-admin');
const path = require('path');

// Path to service account (project root)
const serviceAccountPath = path.join(__dirname, '..', 'service-account.json');

let serviceAccount;
try {
  serviceAccount = require(serviceAccountPath);
} catch (e) {
  console.error('Could not load service-account.json from project root:', serviceAccountPath);
  console.error(e.message);
  process.exit(2);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const docData = {
  createdAt: new Date('2025-08-28T16:13:43Z'),
  email: 'admin@diu.edu.bd',
  lastLogin: new Date('2025-08-28T16:13:43Z'),
  name: 'Super Admin',
  profilePicture: '',
  role: 'superadmin',
  uid: 'sZqvrqYEPfWqz4IKpOi8u8qwdw72',
};

// Default collection - users
const collection = process.argv[2] || 'users';
const docId = docData.uid;

(async () => {
  try {
    const ref = db.collection(collection).doc(docId);
    await ref.set(docData, { merge: true });
    console.log(`✅ Superadmin written to Firestore collection '${collection}' with doc ID '${docId}'`);
    process.exit(0);
  } catch (err) {
    console.error('❌ Failed to write superadmin to Firestore:', err);
    process.exit(1);
  }
})();
