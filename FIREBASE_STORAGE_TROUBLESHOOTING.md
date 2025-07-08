# Firebase Storage Troubleshooting Guide

## Current Issue
Animals are being created successfully in Firestore, but image uploads to Firebase Storage are failing with:
```
StorageException: Object does not exist at location.
Code: -13010 HttpResult: 404
```

## Root Causes
1. **Firebase Storage bucket not properly configured**
2. **Storage rules may be incorrect**
3. **App Check not configured (warning, not critical)**
4. **Storage bucket may not exist or be in wrong region**

## Solutions

### 1. Check Firebase Storage Configuration
1. Go to your Firebase Console
2. Navigate to Storage section
3. Ensure Storage is enabled
4. Check if bucket `farmsheep-85d86.appspot.com` exists
5. Verify storage rules allow authenticated users

### 2. Verify Storage Rules
Your `storage.rules` should allow authenticated users:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Update Firebase Configuration
1. Download the latest `google-services.json` from Firebase Console
2. Replace the existing file in `android/app/`
3. Ensure the storage bucket URL is correct

### 4. Temporary Workaround
The app now handles storage failures gracefully:
- Animals are still created in Firestore
- Users get clear feedback about storage issues
- Photos can be added later when storage is fixed

### 5. Test Storage Directly
Use the Firebase Console to:
1. Try uploading a test file manually
2. Check if the bucket has correct permissions
3. Verify the bucket location matches your project region

## Current Status
✅ **Fixed**: App no longer crashes on storage failures
✅ **Fixed**: Animals are created successfully even if images fail
✅ **Fixed**: Clear user feedback about what succeeded/failed
⚠️ **Pending**: Storage configuration needs to be verified in Firebase Console

## Next Steps
1. Check Firebase Console storage configuration
2. Test the app - animals should be created even if images fail
3. Users will see appropriate messages about image upload status
