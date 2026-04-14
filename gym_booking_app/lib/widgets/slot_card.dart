import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../features/slots/models/slot_model.dart';
import '../core/theme.dart';

class SlotCard extends StatelessWidget {
  final SlotModel slot;
  final bool isBooked;
  final VoidCallback onBook;

  const SlotCard({
    super.key,
    required this.slot,
    required this.isBooked,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final fillPercent =
        slot.capacity > 0 ? slot.bookedCount / slot.capacity : 0.0;
    final statusColor = isBooked
        ? AppTheme.success
        : slot.isFull
            ? AppTheme.error
            : AppTheme.primary;
    final statusLabel = isBooked
        ? 'Booked ✓'
        : slot.isFull
            ? 'Full'
            : '${slot.availableSpots} spots left';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column
                Container(
                  width: 64,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        slot.startTime,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Text('|',
                          style: TextStyle(
                              color: AppTheme.textLight, fontSize: 10)),
                      Text(
                        slot.endTime,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Details
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
                      if (slot.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          slot.description,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textMedium),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              size: 14, color: AppTheme.textMedium),
                          const SizedBox(width: 4),
                          Text(
                            '${slot.bookedCount}/${slot.capacity} booked',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMedium),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Capacity bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fillPercent,
                minHeight: 5,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  slot.isFull ? AppTheme.error : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (slot.isFull || isBooked) ? null : onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBooked
                      ? AppTheme.success
                      : slot.isFull
                          ? AppTheme.textLight
                          : AppTheme.primary,
                  disabledBackgroundColor: isBooked
                      ? AppTheme.success.withOpacity(0.7)
                      : AppTheme.textLight.withOpacity(0.5),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isBooked
                      ? '✓ Already Booked'
                      : slot.isFull
                          ? 'Slot Full'
                          : 'Book This Slot',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
