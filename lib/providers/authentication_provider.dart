import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_manager/providers/user_provider.dart';

import '../logger.dart';
import '../services/auth_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  User? _user;
  late FirebaseAuth _auth;
  bool _firebaseInitialized = false;

  AuthenticationProvider() {
    try {
      _auth = FirebaseAuth.instance;
      _firebaseInitialized = true;

      // Initialize the current user and listen for auth state changes
      _user = _auth.currentUser;
      _auth.authStateChanges().listen((user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      logger.e("Firebase Auth not available: $e");
      _firebaseInitialized = false;
    }
  }

  // Get the current user
  User? get user => _user;

  // Check if the user is authenticated
  bool get isAuthenticated => _user != null;

  // Check if Firebase is initialized
  bool get isFirebaseAvailable => _firebaseInitialized;

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    if (!_firebaseInitialized) {
      throw Exception('Firebase not initialized on this platform');
    }
    try {
      User? signedInUser = await AuthService.signInWithEmail(email, password);
      _user = signedInUser;
      notifyListeners(); // Notify listeners to update UI after sign-in
    } catch (e) {
      logger.e("Sign-in failed: $e");
      rethrow; // Rethrow to handle errors in the UI
    }
  }

  // Register with email and password
  Future<void> register(String email, String password) async {
    if (!_firebaseInitialized) {
      throw Exception('Firebase not initialized on this platform');
    }
    try {
      User? registeredUser =
      await AuthService.registerWithEmail(email, password);
      _user = registeredUser;
      notifyListeners(); // Notify listeners to update UI after registration
    } catch (e) {
      logger.e("Registration failed: $e");
      rethrow;
    }
  }

  // Sign out the user
  Future<void> signOut(BuildContext context) async {
    if (!_firebaseInitialized) {
      throw Exception('Firebase not initialized on this platform');
    }
    try {
      await _auth.signOut();
      // Clear UserProvider data when the user signs out
      Provider.of<UserProvider>(context, listen: false).clearUserProfile();
      _user = null;
      notifyListeners();
    } catch (e) {
      logger.e("Sign-out failed: $e");
    }
  }

  // Re-authenticate the user with email and password
  Future<void> reAuthenticate(String email, String password) async {
    if (!_firebaseInitialized) {
      throw Exception('Firebase not initialized on this platform');
    }
    try {
      await AuthService.reAuthenticate(email, password);
      notifyListeners(); // Notify listeners if re-authentication affects app state
    } catch (e) {
      logger.e("Re-authentication failed: $e");
    }
  }

  // Delete the user account
  Future<void> deleteAccount() async {
    if (!_firebaseInitialized) {
      throw Exception('Firebase not initialized on this platform');
    }
    try {
      await AuthService.deleteAccount();
      _user = null;
      notifyListeners(); // Notify listeners after account deletion
    } catch (e) {
      logger.e("Account deletion failed: $e");
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (!_firebaseInitialized) {
      throw Exception('Firebase not initialized on this platform');
    }
    try {
      await AuthService.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.e("Password reset email failed: $e");
    }
  }
}