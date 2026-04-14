class SlotModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int capacity;
  final int bookedCount;
  final bool isFull;
  final int availableSpots;

  SlotModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
    required this.isFull,
    required this.availableSpots,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    final capacity = json['capacity'] ?? 0;
    final bookedCount = json['bookedCount'] ?? 0;
    return SlotModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      capacity: capacity,
      bookedCount: bookedCount,
      isFull: json['isFull'] ?? bookedCount >= capacity,
      availableSpots: json['availableSpots'] ?? (capacity - bookedCount),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'capacity': capacity,
        'bookedCount': bookedCount,
        'isFull': isFull,
        'availableSpots': availableSpots,
      };
}
