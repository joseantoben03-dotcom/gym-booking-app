import 'package:get/get.dart';
import 'package:dio/dio.dart' show DioException;
import '../../../core/services/api_client.dart';
import '../../auth/models/user_model.dart';

class AdminController extends GetxController {
  ApiClient get _api => Get.find<ApiClient>();

  final RxBool isLoading      = false.obs;
  final RxBool isAdminLoading = false.obs;
  final RxInt  totalUsers     = 0.obs;
  final RxInt  totalAdmins    = 0.obs;
  final RxInt  totalBookings  = 0.obs;
  final RxList bookingsPerDay = [].obs;
  final RxList<UserModel> admins = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    fetchAdmins();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final res = await _api.get('/admin/stats');
      final data = res.data['data'];
      totalUsers.value    = data['totalUsers']    ?? 0;
      totalAdmins.value   = data['totalAdmins']   ?? 0;
      totalBookings.value = data['totalBookings']  ?? 0;
      bookingsPerDay.value = data['bookingsPerDay'] ?? [];
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['message'] ?? 'Failed to fetch stats.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdmins() async {
    try {
      isAdminLoading.value = true;
      final res = await _api.get('/admin/admins');
      final List data = res.data['data']['admins'];
      admins.value = data.map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['message'] ?? 'Failed to fetch admins.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isAdminLoading.value = false;
    }
  }

  Future<bool> addAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isAdminLoading.value = true;
      final res = await _api.post('/admin/admins', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      Get.snackbar('Success', res.data['message'] ?? 'Admin added.',
          snackPosition: SnackPosition.BOTTOM);
      await fetchAdmins();
      await fetchStats();
      return true;
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['message'] ?? 'Failed to add admin.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isAdminLoading.value = false;
    }
  }

  Future<bool> removeAdmin(String adminId, String adminName) async {
    try {
      isAdminLoading.value = true;
      await _api.delete('/admin/admins/$adminId');
      admins.removeWhere((a) => a.id == adminId);
      Get.snackbar('Done', '$adminName has been removed as admin.',
          snackPosition: SnackPosition.BOTTOM);
      await fetchStats();
      return true;
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['message'] ?? 'Failed to remove admin.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isAdminLoading.value = false;
    }
  }
}
