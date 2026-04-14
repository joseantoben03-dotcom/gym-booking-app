import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart' show DioException;
import 'dart:convert';
import '../models/user_model.dart';
import '../../../core/services/api_client.dart';
import '../../../core/constants.dart';
import '../../../core/routes.dart';

class AuthController extends GetxController {
  ApiClient get _api => Get.find<ApiClient>();
  final _storage = GetStorage();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredUser();
  }

  void _loadStoredUser() {
    try {
      final storedToken = _storage.read<String>(AppConstants.tokenKey);
      final storedUserStr = _storage.read<String>(AppConstants.userKey);
      if (storedToken != null &&
          storedToken.isNotEmpty &&
          storedUserStr != null &&
          storedUserStr.isNotEmpty) {
        token.value = storedToken;
        final userMap =
            Map<String, dynamic>.from(jsonDecode(storedUserStr) as Map);
        currentUser.value = UserModel.fromJson(userMap);
      }
    } catch (e) {
      _storage.remove(AppConstants.tokenKey);
      _storage.remove(AppConstants.userKey);
    }
  }

  bool get isLoggedIn => token.value.isNotEmpty && currentUser.value != null;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  // ── Member registration ────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final res = await _api.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      _handleAuthResponse(res.data);
      Get.snackbar('Welcome!', 'Account created successfully.',
          snackPosition: SnackPosition.BOTTOM);
      _navigateAfterAuth();
    } on DioException catch (e) {
      _handleError(e, 'Registration failed.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Admin registration (requires setup key) ────────────────────────────────
  Future<void> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String setupKey,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final res = await _api.post('/auth/register-admin', data: {
        'name': name,
        'email': email,
        'password': password,
        'setupKey': setupKey,
      });
      _handleAuthResponse(res.data);
      Get.snackbar('Admin Account Created!', 'Welcome, ${currentUser.value?.name}.',
          snackPosition: SnackPosition.BOTTOM);
      _navigateAfterAuth();
    } on DioException catch (e) {
      _handleError(e, 'Admin registration failed.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final res = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      _handleAuthResponse(res.data);
      Get.snackbar('Welcome back!', 'Logged in successfully.',
          snackPosition: SnackPosition.BOTTOM);
      _navigateAfterAuth();
    } on DioException catch (e) {
      _handleError(e, 'Login failed.');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _handleAuthResponse(dynamic responseData) {
    final data = responseData['data'] as Map;
    final t = data['token'] as String;
    final u = Map<String, dynamic>.from(data['user'] as Map);
    token.value = t;
    currentUser.value = UserModel.fromJson(u);
    _storage.write(AppConstants.tokenKey, t);
    _storage.write(AppConstants.userKey, jsonEncode(u));
  }

  void _navigateAfterAuth() {
    if (isAdmin) {
      Get.offAllNamed(AppRoutes.adminShell);
    } else {
      Get.offAllNamed(AppRoutes.slots);
    }
  }

  void _handleError(DioException e, String fallback) {
    final msg = e.response?.data is Map
        ? (e.response!.data['message'] ?? fallback)
        : '$fallback Check your connection.';
    _setError(msg);
  }

  void _setError(String msg) {
    errorMessage.value = msg;
    Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
  }

  void logout() {
    currentUser.value = null;
    token.value = '';
    _storage.remove(AppConstants.tokenKey);
    _storage.remove(AppConstants.userKey);
    Get.offAllNamed(AppRoutes.login);
  }
}
