import 'address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
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
    List<AddressModel>? addresses,
    List<String>? wishlist,
    List<String>? storeIds,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email, // Email usually doesn't change, or needs special flow
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
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'wishlist': wishlist,
      'createdAt': createdAt.toIso8601String(),
      // We could add full address serialization here later
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      wishlist: List<String>.from(json['wishlist'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
