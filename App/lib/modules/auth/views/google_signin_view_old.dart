import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/routes/app_routes.dart';

class AuthView extends StatelessWidget {
  AuthView({Key? key}) : super(key: key);

  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // App Logo/Title
              const Icon(Icons.account_balance, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Jan Mitra',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Government Service Portal',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Google Sign-In Button
              Obx(
                () => ElevatedButton.icon(
                  onPressed: _authService.isLoading.value
                      ? null
                      : _handleSignIn,
                  icon: Image.asset(
                    'assets/icons/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.account_circle, color: Colors.white),
                  ),
                  label: Text(
                    _authService.isLoading.value
                        ? 'Signing in...'
                        : 'Continue with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Error Message
              Obx(
                () => _authService.authError.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _authService.authError.value,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

              // Additional Info
              const Text(
                'Sign in to access government services and support tickets',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    try {
      await _authService.signInWithGoogle();
      // Navigation will be handled by the auth state change listener
      Get.offAllNamed(Routes.CITIZEN_HOME);
    } catch (e) {
      // Error is already handled in the service and displayed via authError
      print('Google Sign-In Error: $e');
    }
  }

  Future<void> _handleSignUp() async {
    // For Google Sign-In, sign up is the same as sign in
    await _handleSignIn();
  }
}
