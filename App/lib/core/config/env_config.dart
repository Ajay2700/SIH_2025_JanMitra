import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the application
///
/// This class provides access to environment variables and configuration settings.
/// In a production environment, these values would be loaded from secure sources.
class EnvConfig {
  // Supabase configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-supabase-anon-key-here';

  // Firebase configuration
  static String get firebaseApiKey =>
      dotenv.env['FIREBASE_API_KEY'] ?? 'your-firebase-api-key-here';

  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'your-project.firebaseapp.com';

  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'jan-mitra-project';

  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'jan-mitra-project.appspot.com';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '123456789012';

  static String get firebaseAppId =>
      dotenv.env['FIREBASE_APP_ID'] ??
      '1:123456789012:android:abc123def456ghi789';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String issuesCollection = 'issues';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';

  // Storage buckets (Firebase Storage)
  static const String profileImagesPath = 'profile_images';
  static const String issueImagesPath = 'issue_images';

  // Supabase Storage buckets
  static const String ticketAttachmentsBucket = 'ticket-attachments';

  // App configuration
  static const String governmentName = 'Jan Mitra Government';
  static const String departmentName = 'Citizen Services Department';
  static const String supportEmail = 'support@janmitra.gov.in';
  static const String supportPhone = '+91 1800-123-4567';
  static const String privacyPolicyUrl = 'https://janmitra.gov.in/privacy';
  static const String termsOfServiceUrl = 'https://janmitra.gov.in/terms';

  // Feature flags
  static const bool enableRealtime = true;
  static const bool enableOfflineSupport = false;
  static const bool enableAnalytics = false;
  static const bool useMockServices = false;

  // API configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Log configuration
  static bool get enableVerboseLogging => kDebugMode;

  // Initialize environment configuration
  static Future<void> initialize() async {
    try {
      // Load environment variables from .env file
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
        print('Using default environment values');
      }
    }

    if (kDebugMode) {
      print('Environment configuration initialized');
      print(
        'Supabase URL: ${supabaseUrl.replaceAll(RegExp(r'https://([^.]+)\..*'), 'https://***.supabase.co')}',
      );
      print('Firebase Project ID: $firebaseProjectId');
      print('Realtime enabled: $enableRealtime');
    }
  }
}
