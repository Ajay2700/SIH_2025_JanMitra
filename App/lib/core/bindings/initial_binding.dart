import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/core/services/storage_service.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/data/repository/issue_repository.dart';
import 'package:jan_mitra/data/repository/ticket_repository.dart';
import 'package:jan_mitra/data/services/config_service.dart';
import 'package:jan_mitra/data/services/issue_service.dart';
import 'package:jan_mitra/data/services/issue_service_supabase.dart';
import 'package:jan_mitra/data/services/notification_service.dart';
import 'package:jan_mitra/data/services/realtime_service.dart';
import 'package:jan_mitra/data/services/supabase_service.dart';
import 'package:jan_mitra/data/services/ticket_service.dart';
import 'package:jan_mitra/modules/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services - Use put instead of putAsync for immediate registration
    // FirebaseAuthService is initialized in main.dart to handle errors gracefully
    Get.put(SupabaseService(), permanent: true);
    Get.put(IssueService(), permanent: true);
    Get.put(IssueServiceSupabase(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(RealtimeService(), permanent: true);
    Get.put(TicketService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(ConfigService(), permanent: true);

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<IssueRepository>(() => IssueRepository(), fenix: true);
    Get.lazyPut<TicketRepository>(() => TicketRepository(), fenix: true);

    // Controllers
    Get.lazyPut(() => AuthController(), fenix: true);

    if (kDebugMode) {
      print('All services and repositories initialized');
    }
  }
}
