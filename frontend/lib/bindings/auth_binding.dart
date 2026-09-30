import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/session_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SessionController>()) {
      Get.put<SessionController>(SessionController(), permanent: true);
    }

    Get.lazyPut<AuthController>(() => AuthController());
  }
}
