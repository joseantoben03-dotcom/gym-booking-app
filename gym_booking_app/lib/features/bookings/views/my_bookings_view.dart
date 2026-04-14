import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../bookings/controllers/booking_controller.dart';
import '../../../core/theme.dart';

class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingCtrl = Get.find<BookingController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Obx(() {
        if (bookingCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: bookingCtrl.fetchMyBookings,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textMedium,
                  indicatorColor: AppTheme.primary,
                  tabs: [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _BookingList(
                        bookings: bookingCtrl.upcomingBookings,
                        emptyMessage: 'No upcoming bookings',
                        canCancel: true,
                        onCancel: bookingCtrl.cancelBooking,
                      ),
                      _BookingList(
                        bookings: bookingCtrl.pastBookings,
                        emptyMessage: 'No past bookings',
                        canCancel: false,
                        onCancel: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List bookings;
  final String emptyMessage;
  final bool canCancel;
  final Future<bool> Function(String)? onCancel;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.canCancel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(
                    fontSize: 16, color: AppTheme.textMedium)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) {
        final booking = bookings[i];
        final slot = booking.slot;
        if (slot == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: AppTheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.title.isNotEmpty ? slot.title : 'Gym Session',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, MMM dd yyyy').format(slot.date),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textMedium),
                      ),
                      Text(
                        '${slot.startTime} – ${slot.endTime}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ),
                if (canCancel)
                  TextButton(
                    onPressed: () => _confirmCancel(ctx, booking.id),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppTheme.error)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, String bookingId) {
    Get.dialog(AlertDialog(
      title: const Text('Cancel Booking'),
      content: const Text('Are you sure you want to cancel this booking?'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('No')),
        TextButton(
          onPressed: () {
            Get.back();
            onCancel?.call(bookingId);
          },
          child: const Text('Yes, Cancel',
              style: TextStyle(color: AppTheme.error)),
        ),
      ],
    ));
  }
}
