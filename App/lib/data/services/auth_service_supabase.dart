import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable properties
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString authError = ''.obs;

  // Initialize the service
  Future<AuthService> init() async {
    // Check if user is already authenticated with valid token
    final session = _supabaseClient.auth.currentSession;
    if (session != null && hasValidToken()) {
      await _fetchUserProfile();
      isAuthenticated.value = true;
    } else {
      // Clear any invalid session
      if (session != null) {
        await _supabaseClient.auth.signOut();
      }
      isAuthenticated.value = false;
    }

    // Listen for auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      _handleAuthStateChange(data.event, data.session);
    });

    if (kDebugMode) {
      print('AuthService initialized, authenticated: ${isAuthenticated.value}');
      print('Current token valid: ${hasValidToken()}');
    }

    return this;
  }

  // Handle auth state changes
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    if (kDebugMode) {
      print('Auth state changed: $event');
    }

    switch (event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.tokenRefreshed:
        isAuthenticated.value = true;
        _fetchUserProfile();
        break;
      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.userDeleted:
        isAuthenticated.value = false;
        currentUser.value = null;
        break;
      default:
        break;
    }
  }

  // Fetch the user profile from the database
  Future<void> _fetchUserProfile() async {
    try {
      isLoading.value = true;
      final userId = _supabaseClient.auth.currentUser?.id;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        currentUser.value = UserModel.fromJson(response);
        if (kDebugMode) {
          print('User profile loaded: ${currentUser.value?.name}');
        }
      } else {
        // If user doesn't exist in our database, create them
        if (kDebugMode) {
          print('User profile not found, creating new profile...');
        }
        await _createUserProfile();
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }
  }

  // Create user profile from Supabase auth data
  Future<void> _createUserProfile() async {
    try {
      final authUser = _supabaseClient.auth.currentUser;
      if (authUser == null) return;

      // Extract name from metadata or email
      String name =
          authUser.userMetadata?['full_name'] ??
          authUser.userMetadata?['name'] ??
          authUser.email?.split('@')[0] ??
          'User';

      // Create user profile in our database (use upsert to handle duplicates)
      await _supabaseService.client.from('users').upsert({
        'id': authUser.id,
        'email': authUser.email,
        'name': name,
        'user_type': 'citizen', // Default user type
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Set current user directly to avoid recursive call
      currentUser.value = UserModel.fromJson({
        'id': authUser.id,
        'email': authUser.email,
        'name': name,
        'user_type': 'citizen',
        'phone': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('User profile created successfully: ${currentUser.value?.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
    }
  }

  // Sign up with email and password using JWT tokens
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      isLoading.value = true;
      authError.value = '';

      // Create auth user with JWT token
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create user');
      }

      // Add user profile to users table (even if email confirmation is pending)
      await _supabaseClient.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'phone': phone,
        'user_type': userType,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      isLoading.value = false;

      if (response.session == null) {
        // Email confirmation required
        return {
          'success': true,
          'needsEmailVerification': true,
          'message':
              'Account created successfully! Please check your email and click the verification link to activate your account.',
        };
      } else {
        // User is immediately signed in
        await _fetchUserProfile();
        return {
          'success': true,
          'needsEmailVerification': false,
          'user': currentUser.value!,
        };
      }
    } catch (e) {
      isLoading.value = false;

      // Handle specific error cases
      String errorMessage = e.toString();
      if (errorMessage.contains(
        'duplicate key value violates unique constraint "users_email_key"',
      )) {
        errorMessage =
            'An account with this email already exists. Please use a different email or try signing in.';
      } else if (errorMessage.contains(
        'duplicate key value violates unique constraint',
      )) {
        errorMessage =
            'This email is already registered. Please use a different email or try signing in.';
      } else if (errorMessage.contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (errorMessage.contains('Password should be at least')) {
        errorMessage = 'Password must be at least 6 characters long.';
      }

      authError.value = 'Failed to sign up: $errorMessage';
      throw Exception('Failed to sign up: $errorMessage');
    }
  }

  // Sign in with email and password using JWT tokens
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      authError.value = '';

      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      if (response.session == null) {
        throw Exception('No session created. Please check your credentials.');
      }

      // Fetch user profile after successful authentication
      await _fetchUserProfile();

      isLoading.value = false;

      // Ensure we have a user before returning
      if (currentUser.value == null) {
        throw Exception('Failed to load user profile after sign in');
      }

      return currentUser.value!;
    } catch (e) {
      isLoading.value = false;

      // Handle specific error cases
      String errorMessage = e.toString();
      if (errorMessage.contains('Invalid login credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials and try again.';
      } else if (errorMessage.contains('Email not confirmed')) {
        errorMessage =
            'Please check your email and confirm your account before signing in.';
      } else if (errorMessage.contains('Too many requests')) {
        errorMessage =
            'Too many login attempts. Please wait a moment and try again.';
      } else if (errorMessage.contains('Failed to load user profile')) {
        errorMessage =
            'Account exists but profile could not be loaded. Please contact support.';
      }

      authError.value = 'Failed to sign in: $errorMessage';
      throw Exception('Failed to sign in: $errorMessage');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _supabaseClient.auth.signOut();
      currentUser.value = null;
      isAuthenticated.value = false;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      authError.value = 'Failed to sign out: ${e.toString()}';
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    return currentUser.value;
  }

  // Refresh user profile from database
  Future<void> refreshUserProfile() async {
    await _fetchUserProfile();
  }

  // Create user profile from auth user data
  Future<void> createUserProfileFromAuth() async {
    await _createUserProfile();
  }

  // Get current JWT token
  String? getCurrentToken() {
    final session = _supabaseClient.auth.currentSession;
    return session?.accessToken;
  }

  // Check if user has valid JWT token
  bool hasValidToken() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) return false;

    // Check if token is expired
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000,
    );
    return expiresAt.isAfter(DateTime.now());
  }

  // Resend email verification
  Future<void> resendEmailVerification(String email) async {
    try {
      isLoading.value = true;
      authError.value = '';
      await _supabaseClient.auth.resend(type: OtpType.signup, email: email);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      authError.value = 'Failed to resend verification email: ${e.toString()}';
      throw Exception('Failed to resend verification email: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      authError.value = '';
      await _supabaseClient.auth.resetPasswordForEmail(email);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      authError.value = 'Failed to reset password: ${e.toString()}';
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      isLoading.value = true;
      authError.value = '';

      // Update only provided fields
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (profileImageUrl != null)
        updateData['profile_image_url'] = profileImageUrl;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Update user profile
      await _supabaseClient.from('users').update(updateData).eq('id', userId);

      // Refresh current user data
      await _fetchUserProfile();

      isLoading.value = false;
      return currentUser.value!;
    } catch (e) {
      isLoading.value = false;
      authError.value = 'Failed to update profile: ${e.toString()}';
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
