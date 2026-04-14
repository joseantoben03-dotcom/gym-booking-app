import 'package:get/get.dart';
import '../../features/bookings/controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient is already permanent — no need to register again
    Get.lazyPut<BookingController>(() => BookingController());
  }
}
