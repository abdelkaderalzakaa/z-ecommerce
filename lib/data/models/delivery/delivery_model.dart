import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class DeliveryModel {
  final String id;
  final String name;
  final DeliveryEntityType type;
  final String phone;
  final String? email;
  final String? logo;
  final String status;
  final String? vehicleDetails;
  final List<String> coverageAreas;
  final double baseFee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;
  final bool isPlatformApproved;

  DeliveryModel({
    required this.id,
    required this.name,
    this.type = DeliveryEntityType.company,
    required this.phone,
    this.email,
    this.logo,
    this.status = 'Active',
    this.vehicleDetails,
    this.coverageAreas = const [],
    this.baseFee = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.isPlatformApproved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'phone': phone,
      'email': email,
      'logo': logo,
      'status': status,
      'vehicleDetails': vehicleDetails,
      'coverageAreas': coverageAreas,
      'baseFee': baseFee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'isPlatformApproved': isPlatformApproved,
    };
  }

  factory DeliveryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return DeliveryModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      type: DeliveryEntityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DeliveryEntityType.company,
      ),
      phone: map['phone'] ?? '',
      email: map['email'],
      logo: map['logo'],
      status: map['status'] ?? 'Active',
      vehicleDetails: map['vehicleDetails'],
      coverageAreas: List<String>.from(map['coverageAreas'] ?? []),
      baseFee: (map['baseFee'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      userId: map['userId'],
      isPlatformApproved: map['isPlatformApproved'] ?? false,
    );
  }

  DeliveryModel copyWith({
    String? id,
    String? name,
    DeliveryEntityType? type,
    String? phone,
    String? email,
    String? logo,
    String? status,
    String? vehicleDetails,
    List<String>? coverageAreas,
    double? baseFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isPlatformApproved,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      coverageAreas: coverageAreas ?? this.coverageAreas,
      baseFee: baseFee ?? this.baseFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isPlatformApproved: isPlatformApproved ?? this.isPlatformApproved,
    );
  }
}
