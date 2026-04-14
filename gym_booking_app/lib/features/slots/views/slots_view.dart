import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/slot_controller.dart';
import '../../bookings/controllers/booking_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/routes.dart';
import '../../../core/theme.dart';
import '../../../widgets/slot_card.dart';
import '../../../widgets/date_selector.dart';

class SlotsView extends StatelessWidget {
  const SlotsView({super.key});

  @override
  Widget build(BuildContext context) {
    final slotCtrl = Get.find<SlotController>();
    final bookingCtrl = Get.find<BookingController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Slots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => Get.toNamed(AppRoutes.myBookings),
            tooltip: 'My Bookings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(authCtrl),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Obx(() => Text(
                  'Hello, ${authCtrl.currentUser.value?.name.split(' ').first ?? 'Member'} 👋',
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                )),
          ),
          // Date Selector
          Obx(() => DateSelector(
                selectedDate: slotCtrl.selectedDate.value,
                onDateSelected: slotCtrl.selectDate,
              )),
          // Slots list
          Expanded(
            child: Obx(() {
              if (slotCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (slotCtrl.slots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy,
                          size: 64, color: AppTheme.textLight),
                      const SizedBox(height: 16),
                      const Text('No slots available',
                          style: TextStyle(
                              fontSize: 18, color: AppTheme.textMedium)),
                      const SizedBox(height: 8),
                      Text(
                        'for ${DateFormat('MMM dd, yyyy').format(slotCtrl.selectedDate.value)}',
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    slotCtrl.fetchSlots(date: slotCtrl.selectedDate.value),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slotCtrl.slots.length,
                  itemBuilder: (ctx, i) {
                    final slot = slotCtrl.slots[i];
                    return Obx(() => SlotCard(
                          slot: slot,
                          isBooked: bookingCtrl.hasBookedSlot(slot.id),
                          onBook: () async {
                            await bookingCtrl.bookSlot(slot.id);
                            slotCtrl.fetchSlots(
                                date: slotCtrl.selectedDate.value);
                          },
                        ));
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(AuthController authCtrl) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: authCtrl.logout,
            child: const Text('Logout',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
