import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

import '../common/address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? businessId; // Required only for companyOwner
  final String phoneNumber;
  final String avatarUrl ;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.customer,
    this.businessId,
    this.phoneNumber,
    this.avatarUrl = "",
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    String? businessId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      businessId: businessId ?? this.businessId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'businessId': businessId,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.customer;
    if (json['role'] != null) {
      parsedRole = UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      );
    }

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: parsedRole,
      businessId: json['businessId'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) =>
      UserModel.fromJson(map);

  Map<String, dynamic> toMap() => toJson();

  avatarUrl اذا لم يكن هناك صورة  فستكون صورةافتراضيةحسب الدور 
}
