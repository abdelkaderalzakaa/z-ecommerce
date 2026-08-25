import 'package:z_ecommerce/data/models/delivery/delivery_driver_model.dart';
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
  final bool isOnline;
  final int currentOrdersCount;
  final int totalDeliveredOrders;
  final double totalEarnings;
  final double rating;
  final List<DeliveryDriverModel> drivers;

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
    this.isOnline = true,
    this.currentOrdersCount = 0,
    this.totalDeliveredOrders = 0,
    this.totalEarnings = 0.0,
    this.rating = 5.0,
    this.drivers = const [],
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
      'isOnline': isOnline,
      'currentOrdersCount': currentOrdersCount,
      'totalDeliveredOrders': totalDeliveredOrders,
      'totalEarnings': totalEarnings,
      'rating': rating,
      'drivers': drivers.map((d) => d.toMap()).toList(),
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
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      userId: map['userId'],
      isPlatformApproved: map['isPlatformApproved'] ?? false,
      isOnline: map['isOnline'] ?? true,
      currentOrdersCount: map['currentOrdersCount'] ?? 0,
      totalDeliveredOrders: map['totalDeliveredOrders'] ?? 0,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 5.0).toDouble(),
      drivers: map['drivers'] != null
          ? (map['drivers'] as List)
              .map((d) => DeliveryDriverModel.fromMap(Map<String, dynamic>.from(d)))
              .toList()
          : [],
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
    bool? isOnline,
    int? currentOrdersCount,
    int? totalDeliveredOrders,
    double? totalEarnings,
    double? rating,
    List<DeliveryDriverModel>? drivers,
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
      isOnline: isOnline ?? this.isOnline,
      currentOrdersCount: currentOrdersCount ?? this.currentOrdersCount,
      totalDeliveredOrders: totalDeliveredOrders ?? this.totalDeliveredOrders,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rating: rating ?? this.rating,
      drivers: drivers ?? this.drivers,
    );
  }

  factory DeliveryModel.empty() {
    return DeliveryModel(
      id: '',
      name: '',
      phone: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}
