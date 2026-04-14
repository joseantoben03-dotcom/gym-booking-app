import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../services/api_client.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ApiClient & AuthController are already permanent from InitialBinding.
    // Do NOT re-register them here. This binding is intentionally empty
    // because the splash/login/register pages only need what InitialBinding provides.
  }
}
