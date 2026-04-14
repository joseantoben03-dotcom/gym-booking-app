import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/theme.dart';
import 'admin_dashboard_view.dart';
import 'admin_slots_view.dart';
import 'admin_manage_admins_view.dart';

class AdminShellView extends StatelessWidget {
  const AdminShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl    = Get.find<AuthController>();
    final RxInt index = 0.obs;

    const pages = [
      AdminDashboardView(),
      AdminSlotsView(),
      AdminManageAdminsView(),
    ];

    const titles = ['Dashboard', 'Manage Slots', 'Admins'];

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(titles[index.value]),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => Get.dialog(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                          onPressed: Get.back, child: const Text('Cancel')),
                      TextButton(
                        onPressed: authCtrl.logout,
                        child: const Text('Logout',
                            style: TextStyle(color: AppTheme.error)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: pages[index.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index.value,
            onTap: (i) => index.value = i,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMedium,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_outlined),
                activeIcon: Icon(Icons.event),
                label: 'Slots',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings),
                label: 'Admins',
              ),
            ],
          ),
        ));
  }
}
