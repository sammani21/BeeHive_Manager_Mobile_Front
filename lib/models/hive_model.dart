// models/hive_model.dart
class Hive {
  //final String id;
  final String hiveName;
  final String hiveType;
  final DateTime installationDate;
  final DateTime lastInspection;
  final int strength;
  final String queenStatus;
  final String broodPattern;
  final int honeyStores;
  final int pestLevel;
  final List<String> diseaseSigns;
  final List<Treatment> treatments;
  final String location;
  final int population;

  Hive({
   // required this.id,
    required this.hiveName,
    required this.hiveType,
    required this.installationDate,
    required this.lastInspection,
    required this.strength,
    required this.queenStatus,
    required this.broodPattern,
    required this.honeyStores,
    required this.pestLevel,
    required this.diseaseSigns,
    required this.treatments,
    required this.location,
    required this.population,
  });

  factory Hive.fromJson(Map<String, dynamic> json) {
    return Hive(
     // id: json['_id'],
      hiveName: json['hiveName'],
      hiveType: json['hiveType'],
      installationDate: DateTime.parse(json['installationDate']),
      lastInspection: DateTime.parse(json['lastInspection']),
      strength: json['strength'],
      queenStatus: json['queenStatus'],
      broodPattern: json['broodPattern'],
      honeyStores: json['honeyStores'],
      pestLevel: json['pestLevel'],
      diseaseSigns: List<String>.from(json['diseaseSigns']),
      treatments: List<Treatment>.from(
          json['treatments'].map((x) => Treatment.fromJson(x))),
      location: json['location'],
      population: json['population'],
    );
  }
}

class Treatment {
  final String treatmentType;
  final DateTime applicationDate;
  final String notes;

  Treatment({
    required this.treatmentType,
    required this.applicationDate,
    required this.notes,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      treatmentType: json['treatmentType'],
      applicationDate: DateTime.parse(json['applicationDate']),
      notes: json['notes'],
    );
  }
}