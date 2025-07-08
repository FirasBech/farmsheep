import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  print('Testing Firebase connection...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    print('Testing Firestore connection...');
    
    // Try to read from users collection
    final usersSnapshot = await firestore.collection('users').limit(1).get();
    print('✅ Firestore connection successful. Users collection has ${usersSnapshot.docs.length} documents');
    
    // Try to read from farms collection
    final farmsSnapshot = await firestore.collection('farms').limit(5).get();
    print('✅ Farms collection has ${farmsSnapshot.docs.length} documents');
    
    if (farmsSnapshot.docs.isNotEmpty) {
      print('Farm documents:');
      for (var doc in farmsSnapshot.docs) {
        print('  - ID: ${doc.id}, Data: ${doc.data()}');
      }
    }
    
    // Try to read from animals collection
    final animalsSnapshot = await firestore.collection('animals').limit(5).get();
    print('✅ Animals collection has ${animalsSnapshot.docs.length} documents');
    
    if (animalsSnapshot.docs.isNotEmpty) {
      print('Animal documents:');
      for (var doc in animalsSnapshot.docs) {
        print('  - ID: ${doc.id}, Data: ${doc.data()}');
      }
    }
    
    // Check authentication
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    print('Current user: ${currentUser?.uid ?? 'Not authenticated'}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
