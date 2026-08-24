class SuperAdminModel {
  // 1. البيانات الأساسية الخفيفة
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  
  // 2. التواريخ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SuperAdminModel({
    required this.id,
    this.name = '',
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🔄 Serialization (fromMap, toMap & copyWith)
  // ==========================================

  factory SuperAdminModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SuperAdminModel(
      id: docId ?? map['id'] ?? (map['user']?['id'] ?? ''),
      name: map['name'] ?? (map['user']?['name'] ?? ''),
      email: map['email'] ?? map['user']?['email'],
      phoneNumber: map['phoneNumber'] ?? map['user']?['phoneNumber'],
      avatarUrl: map['avatarUrl'] ?? map['user']?['avatarUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SuperAdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SuperAdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إنشاء كائن SuperAdminModel فارغ بقيم افتراضية
  factory SuperAdminModel.empty() {
    return SuperAdminModel(
      id: '',
      name: '',
    );
  }
}
