import 'package:get/get.dart';
import 'package:dio/dio.dart' show DioException;
import '../models/booking_model.dart';
import '../../../core/services/api_client.dart';

class BookingController extends GetxController {
  ApiClient get _api => Get.find<ApiClient>();

  final RxList<BookingModel> upcomingBookings = <BookingModel>[].obs;
  final RxList<BookingModel> pastBookings = <BookingModel>[].obs;
  final RxList<BookingModel> slotBookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isBooking = false.obs;
  final RxSet<String> bookedSlotIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;
      final res = await _api.get('/bookings/my');
      final data = res.data['data'];
      final List upcoming = data['upcoming'] ?? [];
      final List past = data['past'] ?? [];
      upcomingBookings.value =
          upcoming.map((e) => BookingModel.fromJson(e)).toList();
      pastBookings.value =
          past.map((e) => BookingModel.fromJson(e)).toList();

      bookedSlotIds.value = {
        ...upcomingBookings.map((b) => b.slot?.id ?? ''),
        ...pastBookings.map((b) => b.slot?.id ?? ''),
      }..remove('');
    } on DioException catch (e) {
      Get.snackbar('Error',
          e.response?.data['message'] ?? 'Failed to fetch bookings.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBookingsForSlot(String slotId) async {
    try {
      isLoading.value = true;
      final res = await _api.get('/bookings/slot/$slotId');
      final List data = res.data['data']['bookings'];
      slotBookings.value =
          data.map((e) => BookingModel.fromJson(e)).toList();
    } on DioException catch (e) {
      Get.snackbar('Error',
          e.response?.data['message'] ?? 'Failed to fetch slot bookings.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> bookSlot(String slotId) async {
    try {
      isBooking.value = true;
      await _api.post('/bookings', data: {'slotId': slotId});
      bookedSlotIds.add(slotId);
      await fetchMyBookings();
      Get.snackbar('Booked!', 'Your slot has been booked successfully.',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to book slot.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isBooking.value = false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      isLoading.value = true;
      await _api.delete('/bookings/$bookingId');
      await fetchMyBookings();
      Get.snackbar('Cancelled', 'Booking cancelled.',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on DioException catch (e) {
      Get.snackbar('Error',
          e.response?.data['message'] ?? 'Failed to cancel booking.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool hasBookedSlot(String slotId) => bookedSlotIds.contains(slotId);
}
