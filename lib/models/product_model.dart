class Product {
  final String id;
  final String productName;
  final String productType;
  final String description;
  final double quantity;
  final String unit;
  final double price;
  final DateTime harvestDate;
  final DateTime? expiryDate;
  final String qualityGrade;
  final String originLocation;
  final double? moistureContent;
  final String? waxColor;
  final String? pollenSource;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.productName,
    required this.productType,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.harvestDate,
    this.expiryDate,
    required this.qualityGrade,
    required this.originLocation,
    this.moistureContent,
    this.waxColor,
    this.pollenSource,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      productName: json['productName'],
      productType: json['productType'],
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      price: json['price'].toDouble(),
      harvestDate: DateTime.parse(json['harvestDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      qualityGrade: json['qualityGrade'],
      originLocation: json['originLocation'] ?? '',
      moistureContent: json['moistureContent']?.toDouble(),
      waxColor: json['waxColor'],
      pollenSource: json['pollenSource'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productType': productType,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'harvestDate': harvestDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'qualityGrade': qualityGrade,
      'originLocation': originLocation,
      'moistureContent': moistureContent,
      'waxColor': waxColor,
      'pollenSource': pollenSource,
    };
  }
}