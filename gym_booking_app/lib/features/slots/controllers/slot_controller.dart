import 'package:get/get.dart';
import 'package:dio/dio.dart' show DioException;
import '../models/slot_model.dart';
import '../../../core/services/api_client.dart';

class SlotController extends GetxController {
  ApiClient get _api => Get.find<ApiClient>();

  final RxList<SlotModel> slots = <SlotModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchSlots(date: selectedDate.value);
  }

  Future<void> fetchSlots({DateTime? date, bool upcomingOnly = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> params = {};
      if (date != null) {
        params['date'] =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } else if (upcomingOnly) {
        params['upcoming'] = 'true';
      }

      final res = await _api.get('/slots', queryParameters: params);
      final List data = res.data['data']['slots'];
      slots.value = data.map((e) => SlotModel.fromJson(e)).toList();
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data['message'] ?? 'Failed to load slots.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllSlots() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final res =
          await _api.get('/slots', queryParameters: {'upcoming': 'true'});
      final List data = res.data['data']['slots'];
      slots.value = data.map((e) => SlotModel.fromJson(e)).toList();
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data['message'] ?? 'Failed to load slots.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    fetchSlots(date: date);
  }

  Future<bool> createSlot({
    required String date,
    required String startTime,
    required String endTime,
    required int capacity,
    String title = '',
    String description = '',
  }) async {
    try {
      isLoading.value = true;
      await _api.post('/slots', data: {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'capacity': capacity,
        'title': title,
        'description': description,
      });
      Get.snackbar('Success', 'Slot created successfully.',
          snackPosition: SnackPosition.BOTTOM);
      fetchAllSlots();
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to create slot.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateSlot({
    required String slotId,
    String? date,
    String? startTime,
    String? endTime,
    int? capacity,
    String? title,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> data = {};
      if (date != null) data['date'] = date;
      if (startTime != null) data['startTime'] = startTime;
      if (endTime != null) data['endTime'] = endTime;
      if (capacity != null) data['capacity'] = capacity;
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;

      await _api.put('/slots/$slotId', data: data);
      Get.snackbar('Success', 'Slot updated.',
          snackPosition: SnackPosition.BOTTOM);
      fetchAllSlots();
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to update slot.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteSlot(String slotId) async {
    try {
      isLoading.value = true;
      await _api.delete('/slots/$slotId');
      slots.removeWhere((s) => s.id == slotId);
      Get.snackbar('Deleted', 'Slot deleted.',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on DioException catch (e) {
      Get.snackbar(
          'Error', e.response?.data['message'] ?? 'Failed to delete slot.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
