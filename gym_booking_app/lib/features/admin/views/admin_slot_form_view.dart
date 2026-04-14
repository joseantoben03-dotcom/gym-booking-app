import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../slots/models/slot_model.dart';
import '../../slots/controllers/slot_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_button.dart';

class AdminSlotFormView extends StatefulWidget {
  final SlotModel? slot; // null = create, non-null = edit

  const AdminSlotFormView({super.key, this.slot});

  @override
  State<AdminSlotFormView> createState() => _AdminSlotFormViewState();
}

class _AdminSlotFormViewState extends State<AdminSlotFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _slotCtrl = Get.find<SlotController>();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool get isEditing => widget.slot != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final s = widget.slot!;
      _titleCtrl.text = s.title;
      _descCtrl.text = s.description;
      _capacityCtrl.text = s.capacity.toString();
      _selectedDate = s.date;
      final sp = s.startTime.split(':');
      final ep = s.endTime.split(':');
      _startTime = TimeOfDay(
          hour: int.tryParse(sp[0]) ?? 6,
          minute: int.tryParse(sp[1]) ?? 0);
      _endTime = TimeOfDay(
          hour: int.tryParse(ep[0]) ?? 7,
          minute: int.tryParse(ep[1]) ?? 0);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 6, minute: 0),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      Get.snackbar('Error', 'Please select a date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_startTime == null || _endTime == null) {
      Get.snackbar('Error', 'Please select start and end time',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final startStr = _formatTime(_startTime!);
    final endStr = _formatTime(_endTime!);
    final capacity = int.tryParse(_capacityCtrl.text) ?? 0;

    bool success;
    if (isEditing) {
      success = await _slotCtrl.updateSlot(
        slotId: widget.slot!.id,
        date: dateStr,
        startTime: startStr,
        endTime: endStr,
        capacity: capacity,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
    } else {
      success = await _slotCtrl.createSlot(
        date: dateStr,
        startTime: startStr,
        endTime: endStr,
        capacity: capacity,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
    }

    if (success) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Slot' : 'Create New Slot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Title (optional)',
                hint: 'e.g. Morning Workout',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                hint: 'Brief description...',
                prefixIcon: Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.textMedium, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select Date *'
                            : DateFormat('EEE, MMM dd yyyy')
                                .format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? AppTheme.textLight
                              : AppTheme.textDark,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Start / End time row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickStartTime,
                      child: _TimePickerBox(
                        label: 'Start Time *',
                        value: _startTime == null
                            ? null
                            : _formatTime(_startTime!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickEndTime,
                      child: _TimePickerBox(
                        label: 'End Time *',
                        value:
                            _endTime == null ? null : _formatTime(_endTime!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _capacityCtrl,
                label: 'Capacity *',
                hint: 'e.g. 20',
                prefixIcon: Icons.people_outline,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Capacity is required';
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Obx(() => AppButton(
                    label: isEditing ? 'Update Slot' : 'Create Slot',
                    isLoading: _slotCtrl.isLoading.value,
                    onPressed: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerBox extends StatelessWidget {
  final String label;
  final String? value;

  const _TimePickerBox({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time,
              color: AppTheme.textMedium, size: 18),
          const SizedBox(width: 8),
          Text(
            value ?? label,
            style: TextStyle(
              color: value == null ? AppTheme.textLight : AppTheme.textDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
