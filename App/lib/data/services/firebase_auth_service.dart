import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/models/user_model.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Observable properties
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString authError = ''.obs;

  // Auth state subscription
  StreamSubscription<User?>? _authStateSubscription;

  Future<FirebaseAuthService> init() async {
    try {
      // Listen to auth state changes
      _authStateSubscription = _auth.authStateChanges().listen(
        _onAuthStateChanged,
      );

      if (kDebugMode) {
        print('FirebaseAuthService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService initialization failed: $e');
      }
      // Set as not authenticated if Firebase fails
      isAuthenticated.value = false;
      currentUser.value = null;
    }

    return this;
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      // Convert Firebase User to our UserModel
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name:
            firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'User',
        role: 'citizen', // Default role for Firebase users
        profileImageUrl: firebaseUser.photoURL,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: firebaseUser.metadata.lastSignInTime,
      );

      currentUser.value = userModel;
      isAuthenticated.value = true;
    } else {
      currentUser.value = null;
      isAuthenticated.value = false;
    }

    if (kDebugMode) {
      print(
        'Auth state changed: ${isAuthenticated.value ? 'authenticated' : 'not authenticated'}',
      );
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      authError.value = '';

      if (kDebugMode) {
        print('Starting Google Sign-In process...');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        if (kDebugMode) {
          print('Google Sign-In canceled by user');
        }
        return null;
      }

      if (kDebugMode) {
        print('Google user selected: ${googleUser.email}');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (kDebugMode) {
        print('Got Google auth tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('Created Firebase credential');
      }

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (kDebugMode) {
        print('Firebase authentication successful');
      }

      // Convert Firebase User to our UserModel
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              'User',
          role: 'citizen',
          profileImageUrl: firebaseUser.photoURL,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedAt: firebaseUser.metadata.lastSignInTime,
        );

        currentUser.value = userModel;
        isAuthenticated.value = true;

        if (kDebugMode) {
          print('User model created and authentication completed');
        }

        return userModel;
      }

      return null;
    } catch (e) {
      // Check if this is the specific Pigeon type casting error
      // If Firebase auth succeeded but Pigeon failed, we can still proceed
      if (e.toString().contains('PigeonUserDetails') &&
          _auth.currentUser != null) {
        if (kDebugMode) {
          print(
            'Pigeon error occurred but Firebase auth succeeded, proceeding...',
          );
        }

        // Firebase auth succeeded, create user model from current user
        final firebaseUser = _auth.currentUser!;
        final userModel = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              'User',
          role: 'citizen',
          profileImageUrl: firebaseUser.photoURL,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          updatedAt: firebaseUser.metadata.lastSignInTime,
        );

        currentUser.value = userModel;
        isAuthenticated.value = true;

        if (kDebugMode) {
          print('Authentication completed successfully despite Pigeon error');
        }

        return userModel;
      }

      // For other errors, show the error
      authError.value = 'Google sign-in failed: $e';
      if (kDebugMode) {
        print('Google sign-in error: $e');
        print('Error type: ${e.runtimeType}');
        print('Error stack: ${StackTrace.current}');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      authError.value = '';

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // The user will be set by the auth state listener
      return currentUser.value;
    } catch (e) {
      authError.value = 'Sign-in failed: $e';
      if (kDebugMode) {
        print('Email sign-in error: $e');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      isLoading.value = true;
      authError.value = '';

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update the display name
      await userCredential.user?.updateDisplayName(name);

      // The user will be set by the auth state listener
      return currentUser.value;
    } catch (e) {
      authError.value = 'Sign-up failed: $e';
      if (kDebugMode) {
        print('Email sign-up error: $e');
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign-out error: $e');
      }
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    return currentUser.value;
  }

  // Check if user has valid token
  bool hasValidToken() {
    return _auth.currentUser != null;
  }

  // Get current Firebase user
  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    super.onClose();
  }
}
