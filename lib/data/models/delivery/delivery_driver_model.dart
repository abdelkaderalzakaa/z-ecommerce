class DeliveryDriverModel {
  final String id;
  final String name;
  final String phone;
  final String? vehicleNumber;
  final String? vehicleType;
  final bool isAvailable;
  final int deliveredCount;
  final double rating;

  const DeliveryDriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber,
    this.vehicleType,
    this.isAvailable = true,
    this.deliveredCount = 0,
    this.rating = 5.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'isAvailable': isAvailable,
      'deliveredCount': deliveredCount,
      'rating': rating,
    };
  }

  factory DeliveryDriverModel.fromMap(Map<String, dynamic> map) {
    return DeliveryDriverModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      vehicleNumber: map['vehicleNumber'],
      vehicleType: map['vehicleType'],
      isAvailable: map['isAvailable'] ?? true,
      deliveredCount: map['deliveredCount'] ?? 0,
      rating: (map['rating'] ?? 5.0).toDouble(),
    );
  }

  DeliveryDriverModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleNumber,
    String? vehicleType,
    bool? isAvailable,
    int? deliveredCount,
    double? rating,
  }) {
    return DeliveryDriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isAvailable: isAvailable ?? this.isAvailable,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      rating: rating ?? this.rating,
    );
  }
}
