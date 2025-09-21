import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/core/ui/app_loading.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // AuthController will be initialized via bindings
  final RxString loadingText = 'Loading...'.obs;
  final RxString errorText = ''.obs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('Splash screen initializing...');
      loadingText.value = 'Initializing services...';

      // Wait for services to initialize with timeout - check if firebaseInitialized flag is available
      int attempts = 0;
      bool firebaseInitialized = false;
      bool timeoutReached = false;

      while (attempts < 30 && !timeoutReached) {
        // Wait up to 6 seconds
        try {
          firebaseInitialized =
              Get.find<bool>(tag: 'firebaseInitialized') ?? false;
          break; // Flag found, exit loop
        } catch (e) {
          // Flag not available yet, wait and try again
          await Future.delayed(Duration(milliseconds: 200));
          attempts++;

          // Check for timeout after 3 seconds (15 attempts)
          if (attempts >= 15) {
            timeoutReached = true;
            print(
              'Firebase initialization timeout reached, proceeding without Firebase...',
            );
          }
        }
      }

      loadingText.value = 'Checking authentication...';

      if (firebaseInitialized && Get.isRegistered<FirebaseAuthService>()) {
        final authService = Get.find<FirebaseAuthService>();

        // Wait for auth state to be determined with timeout
        int authAttempts = 0;
        while (authAttempts < 15) {
          // Wait up to 3 seconds
          if (authService.currentUser.value != null ||
              !authService.isLoading.value) {
            break;
          }
          await Future.delayed(Duration(milliseconds: 200));
          authAttempts++;
        }

        if (authService.isAuthenticated.value &&
            authService.currentUser.value != null) {
          print('User is authenticated, navigating to services home...');
          loadingText.value = 'Welcome back!';
          await Future.delayed(Duration(milliseconds: 500));
          Get.offAllNamed(Routes.SERVICES_HOME);
        } else {
          print('User not authenticated, navigating to auth...');
          loadingText.value = 'Ready to get started!';
          await Future.delayed(Duration(milliseconds: 500));
          Get.offAllNamed(Routes.AUTH);
        }
      } else {
        // Firebase not available or timeout reached, skip authentication and go to services
        print(
          'Firebase not available or timeout reached, proceeding to services...',
        );
        loadingText.value = 'Loading services...';
        await Future.delayed(Duration(milliseconds: 500));
        Get.offAllNamed(Routes.SERVICES_HOME);
      }
    } catch (e) {
      errorText.value = 'Error initializing app: $e';
      print('Splash error: $e');
      // Even on error, try to proceed to services
      await Future.delayed(Duration(milliseconds: 1000));
      Get.offAllNamed(Routes.SERVICES_HOME);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Icon(Icons.location_city, size: 100, color: Colors.white),
            SizedBox(height: 24),

            // App Name
            Text(
              'Jan Mitra',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // App Tagline
            Text(
              'Empowering Citizens, Improving Cities',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),

            // Loading Spinner
            Obx(() {
              if (errorText.isNotEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Initialization Failed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[300],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        errorText.value,
                        style: TextStyle(color: Colors.red[300]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        errorText.value = '';
                        _initializeApp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              return AppLoading(
                message: loadingText.value,
                type: AppLoadingType.bounce,
                color: Colors.white,
              );
            }),
          ],
        ),
      ),
    );
  }
}
