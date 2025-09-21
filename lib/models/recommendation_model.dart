// models/recommendation_model.dart
class Recommendation {
  final String id;
  final String hiveId;
  final String hiveName;
  final String location;
  final String recommendations;
  final DateTime date;

  Recommendation({
    required this.id,
    required this.hiveId,
    required this.hiveName,
    required this.location,
    required this.recommendations,
    required this.date,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final hiveData = json['hiveId'];

    return Recommendation(
      id: json['_id'] ?? 'Unknown ID',
      hiveId: hiveData is Map
          ? (hiveData['_id'] ?? 'Unknown HiveId')
          : (hiveData ?? 'Unknown HiveId'),
      hiveName: hiveData is Map
          ? (hiveData['hiveName'] ?? 'Unknown Hive')
          : 'Unknown Hive',
      location: hiveData is Map
          ? (hiveData['location'] ?? 'Unknown Location')
          : 'Unknown Location',
      recommendations: json['recommendations'] ?? 'No recommendations available',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}