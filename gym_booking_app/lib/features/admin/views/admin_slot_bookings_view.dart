import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../slots/models/slot_model.dart';
import '../../bookings/controllers/booking_controller.dart';
import '../../../core/theme.dart';

class AdminSlotBookingsView extends StatefulWidget {
  final SlotModel slot;
  const AdminSlotBookingsView({super.key, required this.slot});

  @override
  State<AdminSlotBookingsView> createState() => _AdminSlotBookingsViewState();
}

class _AdminSlotBookingsViewState extends State<AdminSlotBookingsView> {
  late final BookingController _bookingCtrl;

  @override
  void initState() {
    super.initState();
    _bookingCtrl = Get.find<BookingController>();
    _bookingCtrl.fetchBookingsForSlot(widget.slot.id);
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    return Scaffold(
      appBar: AppBar(
        title: Text(slot.title.isNotEmpty ? slot.title : 'Slot Members'),
      ),
      body: Column(
        children: [
          // Slot info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primary.withOpacity(0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM dd yyyy').format(slot.date),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark),
                ),
                Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                        label: 'Capacity: ${slot.capacity}',
                        color: AppTheme.primary),
                    const SizedBox(width: 8),
                    _InfoChip(
                        label: 'Booked: ${slot.bookedCount}',
                        color: AppTheme.success),
                    const SizedBox(width: 8),
                    _InfoChip(
                        label: 'Available: ${slot.availableSpots}',
                        color: slot.isFull
                            ? AppTheme.error
                            : AppTheme.textMedium),
                  ],
                ),
              ],
            ),
          ),
          // Members list
          Expanded(
            child: Obx(() {
              if (_bookingCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_bookingCtrl.slotBookings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: AppTheme.textLight),
                      SizedBox(height: 16),
                      Text('No members booked yet',
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textMedium)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookingCtrl.slotBookings.length,
                itemBuilder: (ctx, i) {
                  final booking = _bookingCtrl.slotBookings[i];
                  final user = booking.userId;
                  // Access populated user data from booking JSON
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.15),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        _getUserName(booking),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark),
                      ),
                      subtitle: Text(
                        _getUserEmail(booking),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMedium),
                      ),
                      trailing: Text(
                        DateFormat('MMM dd').format(booking.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textLight),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getUserName(booking) {
    try {
      return booking.userName ?? 'Member';
    } catch (_) {
      return 'Member';
    }
  }

  String _getUserEmail(booking) {
    try {
      return booking.userEmail ?? '';
    } catch (_) {
      return '';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
