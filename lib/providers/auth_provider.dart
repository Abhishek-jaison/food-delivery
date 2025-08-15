import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to authentication state changes
    _firebaseService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Convert Firebase user to our UserModel and cache it
        final userModel = UserModel.fromFirebaseUser(firebaseUser);
        _user = userModel;
        await HiveService.cacheUser(userModel);
      } else {
        _user = null;
        await HiveService.clearUserCache();
      }
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential result = await _firebaseService
          .createUserWithEmailAndPassword(email, password);

      // Update display name if provided
      if (displayName != null) {
        await _firebaseService.updateUserProfile(displayName: displayName);
      }

      // Save user data to Firestore
      await _firebaseService.saveUserData(
        uid: result.user!.uid,
        email: email,
        displayName: displayName,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in flow
        _setLoading(false);
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final result = await _firebaseService.signInWithCredential(credential);

      if (result.user != null) {
        // Save user data to Firestore
        await _firebaseService.saveUserData(
          uid: result.user!.uid,
          email: result.user!.email ?? '',
          displayName: result.user!.displayName,
          photoURL: result.user!.photoURL,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Google Sign-In failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      await _firebaseService.signOut();
      await HiveService.clearAllCache();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Update cached user data
      if (_user != null) {
        _user = _user!.copyWith(
          displayName: displayName ?? _user!.displayName,
          photoURL: photoURL ?? _user!.photoURL,
        );
        await HiveService.cacheUser(_user!);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Check if user is signed in with Google
  bool isSignedInWithGoogle() {
    final firebaseUser = _firebaseService.currentUser;
    if (firebaseUser != null) {
      for (final provider in firebaseUser.providerData) {
        if (provider.providerId == 'google.com') {
          return true;
        }
      }
    }
    return false;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
