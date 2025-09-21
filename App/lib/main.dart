import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';
import 'package:jan_mitra/core/bindings/initial_binding.dart';
import 'package:jan_mitra/routes/app_pages.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:jan_mitra/data/services/firebase_service.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/core/config/env_config.dart';
import 'package:jan_mitra/data/services/issue_service_supabase.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize environment configuration
    await EnvConfig.initialize();

    // Initialize services
    await initServices();

    runApp(JanMitraApp());

    print('App started successfully');
  } catch (e, stackTrace) {
    print('Error starting app: $e');
    print('Stack trace: $stackTrace');

    // Run app with error UI if initialization fails
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> initServices() async {
  try {
    // Initialize Supabase first (required for database operations)
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    print('Supabase initialized successfully');

    // Put SupabaseService before dependent services
    Get.put(SupabaseService(), permanent: true);
    print('SupabaseService put successfully');

    // Initialize Firebase (optional - app should work without it)
    bool firebaseInitialized = false;
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: EnvConfig.firebaseApiKey,
          authDomain: EnvConfig.firebaseAuthDomain,
          projectId: EnvConfig.firebaseProjectId,
          storageBucket: EnvConfig.firebaseStorageBucket,
          messagingSenderId: EnvConfig.firebaseMessagingSenderId,
          appId: EnvConfig.firebaseAppId,
        ),
      );
      print('Firebase initialized successfully');
      firebaseInitialized = true;

      // Initialize Firebase services
      final firebaseService = FirebaseService();
      await firebaseService.init();
      Get.put(firebaseService);

      // Initialize Firebase Auth Service
      try {
        final firebaseAuthService = FirebaseAuthService();
        await firebaseAuthService.init();
        Get.put(firebaseAuthService);
      } catch (authError) {
        print('Firebase Auth Service initialization failed: $authError');
        // Create a fallback auth service
        final fallbackAuthService = FirebaseAuthService();
        fallbackAuthService.isAuthenticated.value = false;
        fallbackAuthService.currentUser.value = null;
        Get.put(fallbackAuthService);
      }
    } catch (firebaseError) {
      print(
        'Firebase initialization failed (app will work with limited auth): $firebaseError',
      );
      firebaseInitialized = false; // Ensure flag is set to false
    }

    // Initialize Issue Service (uses Supabase)
    print(
      'Checking SupabaseService registration before putting IssueServiceSupabase: ${Get.isRegistered<SupabaseService>()}',
    );
    Get.put(IssueServiceSupabase());
    print('IssueServiceSupabase put successfully');

    // Store Firebase initialization status for the app to use
    Get.put<bool>(firebaseInitialized, tag: 'firebaseInitialized');

    print('All services initialized successfully');
  } catch (e) {
    print('Error initializing services: $e');
    // Don't throw - let the app run with limited functionality
    print(
      'App will run with limited functionality due to initialization errors',
    );
  }
}

class JanMitraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jan Mitra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme preference
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      initialBinding: InitialBinding(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jan Mitra - Error',
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
