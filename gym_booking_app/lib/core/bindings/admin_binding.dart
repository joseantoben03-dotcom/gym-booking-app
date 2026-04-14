import 'package:get/get.dart';
import '../../features/admin/controllers/admin_controller.dart';
import '../../features/slots/controllers/slot_controller.dart';
import '../../features/bookings/controllers/booking_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient is already permanent — no need to register again
    Get.lazyPut<AdminController>(() => AdminController());
    Get.lazyPut<SlotController>(() => SlotController());
    Get.lazyPut<BookingController>(() => BookingController());
  }
}
