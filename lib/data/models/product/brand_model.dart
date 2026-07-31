class BrandModel {
  final String id;
  final String? businessId;
  final String name;
  final String? logoUrl;
  final String? description;

  const BrandModel({
    required this.id,
    this.businessId,
    required this.name,
    this.logoUrl,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
    };
  }

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? '',
      businessId: json['businessId'],
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'],
      description: json['description'],
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
