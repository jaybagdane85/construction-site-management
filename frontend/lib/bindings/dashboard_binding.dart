import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/session_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SessionController>()) {
      Get.put<SessionController>(SessionController(), permanent: true);
    }

    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
