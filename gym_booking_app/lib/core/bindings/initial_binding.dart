import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/slots/controllers/slot_controller.dart';
import '../../features/bookings/controllers/booking_controller.dart';
import '../../features/admin/controllers/admin_controller.dart';
import '../services/api_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient is a permanent singleton — registered once, used everywhere
    Get.put<ApiClient>(ApiClient(), permanent: true);
    // AuthController is permanent — persists across all routes
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
