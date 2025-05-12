import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Phone number verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+972522628803',
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }
  
  // Sign in with phone credential
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    
    // Create or update user document in Firestore
    if (userCredential.user != null) {
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create new user
        final newUser = AppUser(
          uid: userCredential.user!.uid,
          phoneNumber: userCredential.user!.phoneNumber ?? '',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      } else {
        // Update last login
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': DateTime.now(),
        });
      }
    }
    
    notifyListeners();
    return userCredential;
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
  
  // Get user data
  Future<AppUser?> getUserData() async {
    if (currentUser == null) return null;
    
    final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (!userDoc.exists) return null;
    
    return AppUser.fromMap(userDoc.data()!, currentUser!.uid);
  }
  
  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoUrl}) async {
    if (currentUser == null) return;
    
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    
    await _firestore.collection('users').doc(currentUser!.uid).update(updates);
    notifyListeners();
  }
}
