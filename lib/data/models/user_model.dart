import 'address_model.dart';

enum UserRole {
  superAdmin,
  companyOwner,
  customer,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? companyId; // Required only for companyOwner
  final String? phoneNumber;
  final String? avatarUrl;
  final List<AddressModel> addresses;
  final List<String> wishlist; // List of Product IDs
  final List<String> storeIds; // List of Company/Store IDs the user can access
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.customer, // Default to customer
    this.companyId,
    this.phoneNumber,
    this.avatarUrl,
    this.addresses = const [],
    this.wishlist = const [],
    this.storeIds = const [],
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    String? companyId,
    List<AddressModel>? addresses,
    List<String>? wishlist,
    List<String>? storeIds,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email, 
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addresses: addresses ?? this.addresses,
      wishlist: wishlist ?? this.wishlist,
      storeIds: storeIds ?? this.storeIds,
      createdAt: createdAt,
    );
  }

  // Basic JSON serialization for future shared_preferences or API usage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'companyId': companyId,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'wishlist': wishlist,
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
      companyId: json['companyId'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      wishlist: List<String>.from(json['wishlist'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
