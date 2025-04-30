class CropPrice {
  final String id;
  final String cropName;
  final String cropType;
  final String marketName;
  final double pricePerKg;
  final double pricePerQuintal;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  CropPrice({
    required this.id,
    required this.cropName,
    required this.cropType,
    required this.marketName,
    required this.pricePerKg,
    required this.pricePerQuintal,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CropPrice.fromJson(Map<String, dynamic> json) {
    return CropPrice(
      id: json['_id'] ?? '',
      cropName: json['cropName'] ?? '',
      cropType: json['cropType'] ?? '',
      marketName: json['marketName'] ?? '',
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      pricePerQuintal: (json['pricePerQuintal'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id.isEmpty ? null : id,
      'cropName': cropName,
      'cropType': cropType,
      'marketName': marketName,
      'pricePerKg': pricePerKg,
      'pricePerQuintal': pricePerQuintal,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CropPrice copyWith({
    String? id,
    String? cropName,
    String? cropType,
    String? marketName,
    double? pricePerKg,
    double? pricePerQuintal,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropPrice(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      cropType: cropType ?? this.cropType,
      marketName: marketName ?? this.marketName,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      pricePerQuintal: pricePerQuintal ?? this.pricePerQuintal,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}