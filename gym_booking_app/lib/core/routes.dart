import 'package:get/get.dart';
import '../features/auth/views/splash_view.dart';
import '../features/auth/views/login_view.dart';
import '../features/auth/views/register_view.dart';
import '../features/auth/views/admin_register_view.dart';
import '../features/slots/views/slots_view.dart';
import '../features/bookings/views/my_bookings_view.dart';
import '../features/admin/views/admin_shell_view.dart';
import '../core/bindings/auth_binding.dart';
import '../core/bindings/slot_binding.dart';
import '../core/bindings/booking_binding.dart';
import '../core/bindings/admin_binding.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String adminRegister = '/admin-register';
  static const String slots = '/slots';
  static const String myBookings = '/my-bookings';
  static const String adminShell = '/admin';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: adminRegister,
      page: () => const AdminRegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: slots,
      page: () => const SlotsView(),
      binding: SlotBinding(),
    ),
    GetPage(
      name: myBookings,
      page: () => const MyBookingsView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: adminShell,
      page: () => const AdminShellView(),
      binding: AdminBinding(),
    ),
  ];
}
