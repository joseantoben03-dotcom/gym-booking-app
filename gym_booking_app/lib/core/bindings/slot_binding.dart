import 'package:get/get.dart';
import '../../features/slots/controllers/slot_controller.dart';
import '../../features/bookings/controllers/booking_controller.dart';

class SlotBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient is already permanent — no need to register again
    Get.lazyPut<SlotController>(() => SlotController());
    Get.lazyPut<BookingController>(() => BookingController());
  }
}
