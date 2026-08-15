class BrandModel {
  final String id;
  final List<String> businessIds; // قائمة المتاجر التي قامت بتفعيل الماركة
  final String name;
  final String? logoUrl;
  final String? description;
  final bool isGlobal; // هل الماركة عامة للجميع؟

  String? get businessId => businessIds.isNotEmpty ? businessIds.first : null;

  const BrandModel({
    required this.id,
    this.businessIds = const [],
    required this.name,
    this.logoUrl,
    this.description,
    this.isGlobal = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessIds': businessIds,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'isGlobal': isGlobal,
    };
  }

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? '',
      businessIds: List<String>.from(json['businessIds'] ?? []),
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'],
      description: json['description'],
      isGlobal: json['isGlobal'] ?? false,
    );
  }

  BrandModel copyWith({
    String? id,
    List<String>? businessIds,
    String? name,
    String? logoUrl,
    String? description,
    bool? isGlobal,
  }) {
    return BrandModel(
      id: id ?? this.id,
      businessIds: businessIds ?? this.businessIds,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      isGlobal: isGlobal ?? this.isGlobal,
    );
  }

  /// إنشاء كائن BrandModel فارغ بقيم افتراضية
  factory BrandModel.empty() {
    return const BrandModel(
      id: '',
      name: '',
    );
  }
}
