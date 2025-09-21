class Beekeeper {
  final String id;
  final String name;
  final String email;

  Beekeeper({required this.id, required this.name, required this.email});

  factory Beekeeper.fromJson(Map<String, dynamic> json) {
    return Beekeeper(
      id: json['_id'] ?? '',
      name: json['name'] ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] ?? '',
    );
  }

  Object? toJson() {}
}
