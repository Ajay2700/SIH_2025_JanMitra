import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/config/env_config.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';

class ConfigService extends GetxService {
  final SupabaseService? _supabaseService = Get.isRegistered<SupabaseService>()
      ? Get.find<SupabaseService>()
      : null;
  final RxBool isMockEnabled = EnvConfig.useMockServices.obs;

  // App configuration
  final RxString governmentName = EnvConfig.governmentName.obs;
  final RxString departmentName = EnvConfig.departmentName.obs;
  final RxString supportEmail = EnvConfig.supportEmail.obs;
  final RxString supportPhone = EnvConfig.supportPhone.obs;
  final RxString privacyPolicyUrl = EnvConfig.privacyPolicyUrl.obs;
  final RxString termsOfServiceUrl = EnvConfig.termsOfServiceUrl.obs;

  // Feature flags
  final RxBool enableFeedbackFeature = true.obs;
  final RxBool enableVoiceInputFeature = true.obs;
  final RxBool enableNotifications = true.obs;
  final RxBool enableLocationTracking = true.obs;
  final RxBool enableAnalytics = true.obs;

  // Cache settings
  final RxInt maxCacheAgeInDays = 7.obs;

  // Initialize with configuration
  Future<ConfigService> init() async {
    // For production, load configuration from Supabase
    if (!isMockEnabled.value && _supabaseService != null) {
      await _loadConfigFromSupabase();
    }

    return this;
  }

  Future<void> _loadConfigFromSupabase() async {
    try {
      final response = await _supabaseService!.fetchData('settings');

      for (var setting in response) {
        final key = setting['key'];
        final value = setting['value'];

        switch (key) {
          case 'government_name':
            governmentName.value = value['value'];
            break;
          case 'department_name':
            departmentName.value = value['value'];
            break;
          case 'support_email':
            supportEmail.value = value['value'];
            break;
          case 'support_phone':
            supportPhone.value = value['value'];
            break;
          case 'privacy_policy_url':
            privacyPolicyUrl.value = value['value'];
            break;
          case 'terms_of_service_url':
            termsOfServiceUrl.value = value['value'];
            break;
          case 'enable_feedback_feature':
            enableFeedbackFeature.value = value['value'];
            break;
          case 'enable_voice_input_feature':
            enableVoiceInputFeature.value = value['value'];
            break;
          case 'enable_notifications':
            enableNotifications.value = value['value'];
            break;
          case 'enable_location_tracking':
            enableLocationTracking.value = value['value'];
            break;
          case 'enable_analytics':
            enableAnalytics.value = value['value'];
            break;
          case 'max_cache_age_in_days':
            maxCacheAgeInDays.value = value['value'];
            break;
        }
      }

      if (kDebugMode) {
        print('Configuration loaded from Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load configuration from Supabase: $e');
      }
      // Continue with default configuration
    }
  }

  // Get a configuration value by key
  dynamic getConfig(String key) {
    switch (key) {
      case 'government_name':
        return governmentName.value;
      case 'department_name':
        return departmentName.value;
      case 'support_email':
        return supportEmail.value;
      case 'support_phone':
        return supportPhone.value;
      case 'privacy_policy_url':
        return privacyPolicyUrl.value;
      case 'terms_of_service_url':
        return termsOfServiceUrl.value;
      case 'enable_feedback_feature':
        return enableFeedbackFeature.value;
      case 'enable_voice_input_feature':
        return enableVoiceInputFeature.value;
      case 'enable_notifications':
        return enableNotifications.value;
      case 'enable_location_tracking':
        return enableLocationTracking.value;
      case 'enable_analytics':
        return enableAnalytics.value;
      case 'max_cache_age_in_days':
        return maxCacheAgeInDays.value;
      default:
        return null;
    }
  }
}
