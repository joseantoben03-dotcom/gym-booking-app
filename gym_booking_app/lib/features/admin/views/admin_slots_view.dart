import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../slots/controllers/slot_controller.dart';
import '../../slots/models/slot_model.dart';
import '../../../core/theme.dart';
import 'admin_slot_bookings_view.dart';
import 'admin_slot_form_view.dart';

class AdminSlotsView extends StatelessWidget {
  const AdminSlotsView({super.key});

  @override
  Widget build(BuildContext context) {
    final slotCtrl = Get.find<SlotController>();

    // Fetch all upcoming slots when this view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      slotCtrl.fetchAllSlots();
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AdminSlotFormView()),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Slot', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
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
                const Text('No slots found',
                    style:
                        TextStyle(fontSize: 18, color: AppTheme.textMedium)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AdminSlotFormView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Create First Slot'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: slotCtrl.fetchAllSlots,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: slotCtrl.slots.length,
            itemBuilder: (ctx, i) {
              final slot = slotCtrl.slots[i];
              return _AdminSlotCard(slot: slot, slotCtrl: slotCtrl);
            },
          ),
        );
      }),
    );
  }
}

class _AdminSlotCard extends StatelessWidget {
  final SlotModel slot;
  final SlotController slotCtrl;

  const _AdminSlotCard({required this.slot, required this.slotCtrl});

  @override
  Widget build(BuildContext context) {
    final fillPercent =
        slot.capacity > 0 ? slot.bookedCount / slot.capacity : 0.0;
    final fillColor = slot.isFull
        ? AppTheme.error
        : fillPercent > 0.7
            ? AppTheme.warning
            : AppTheme.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.title.isNotEmpty ? slot.title : 'Gym Session',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
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
                // Capacity badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: fillColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${slot.bookedCount}/${slot.capacity}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fillColor,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fillPercent.toDouble(),
                minHeight: 6,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation<Color>(fillColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => Get.to(
                    () => AdminSlotBookingsView(slot: slot),
                  ),
                  icon: const Icon(Icons.people_outline,
                      size: 16, color: AppTheme.primary),
                  label: const Text('Members',
                      style: TextStyle(color: AppTheme.primary, fontSize: 13)),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () =>
                      Get.to(() => AdminSlotFormView(slot: slot)),
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppTheme.warning),
                  label: const Text('Edit',
                      style:
                          TextStyle(color: AppTheme.warning, fontSize: 13)),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _confirmDelete(slot.id),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: AppTheme.error),
                  label: const Text('Delete',
                      style: TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String slotId) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Slot'),
      content: const Text(
          'This will delete the slot and cancel all associated bookings. Continue?'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            slotCtrl.deleteSlot(slotId);
          },
          child:
              const Text('Delete', style: TextStyle(color: AppTheme.error)),
        ),
      ],
    ));
  }
}
