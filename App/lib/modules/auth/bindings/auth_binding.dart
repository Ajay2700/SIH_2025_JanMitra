import 'package:get/get.dart';
import 'package:jan_mitra/data/repository/auth_repository.dart';
import 'package:jan_mitra/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(AuthRepository());
    }
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
