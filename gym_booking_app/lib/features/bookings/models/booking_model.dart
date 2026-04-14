import '../../slots/models/slot_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final SlotModel? slot;
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.slot,
    required this.status,
    required this.createdAt,
  });

  bool get isBooked => status == 'booked';
  bool get isCancelled => status == 'cancelled';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String uid = '';
    String? uname;
    String? uemail;

    if (json['user'] is Map) {
      uid = json['user']['_id'] ?? json['user']['id'] ?? '';
      uname = json['user']['name'];
      uemail = json['user']['email'];
    } else {
      uid = json['user'] ?? '';
    }

    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: uid,
      userName: uname,
      userEmail: uemail,
      slot: json['slot'] != null && json['slot'] is Map
          ? SlotModel.fromJson(json['slot'])
          : null,
      status: json['status'] ?? 'booked',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
