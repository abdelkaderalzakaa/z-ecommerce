import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import '../auth/user_model.dart';

class SuperAdminModel {
  // 1. البيانات الأساسية
  final UserModel user;

  final List<SocialModel> socials;
  final LocalizationAdmin localizationAdmin;
  final ThemeAdmin themeAdmin;
  
  // 2. التواريخ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SuperAdminModel({
    required this.user,
    this.createdAt,
    this.updatedAt,
    required this.socials,
    required this.localizationAdmin,
    required this.themeAdmin,
  });

  // ==========================================
  // 🧮 Getters & Helpers
  // ==========================================

  /// معرف السوبر أدمن المباشر من UserModel
  String get id => user.id;

  // ==========================================
  // 🔄 Serialization (fromMap, toMap & copyWith)
  // ==========================================

  factory SuperAdminModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SuperAdminModel(
      user: UserModel.fromMap(map['user'] ?? {}),
      socials: map['socials'] != null
          ? (map['socials'] as List<dynamic>)
                .map((e) => SocialModel.fromMap(e))
                .toList()
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
      localizationAdmin: LocalizationAdmin.fromMap(
        map['localizationAdmin'] ?? {},
      ),
      themeAdmin: map['themeAdmin'] != null
          ? ThemeAdmin.fromMap(map['themeAdmin'])
          : ThemeAdmin.empty(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user.toMap(),
      'socials': socials.map((e) => e.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'localizationAdmin': localizationAdmin.toMap(),
      'themeAdmin': themeAdmin.toMap(),
    };
  }

  SuperAdminModel copyWith({
    UserModel? user,
    List<SocialModel>? socials,
    DateTime? createdAt,
    DateTime? updatedAt,
    LocalizationAdmin? localizationAdmin,
    ThemeAdmin? themeAdmin,
  }) {
    return SuperAdminModel(
      user: user ?? this.user,
      socials: socials ?? this.socials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localizationAdmin: localizationAdmin ?? this.localizationAdmin,
      themeAdmin: themeAdmin ?? this.themeAdmin,
    );
  }

  /// إنشاء كائن SuperAdminModel فارغ بقيم افتراضية
  factory SuperAdminModel.empty() {
    return SuperAdminModel(
      user: UserModel.empty(),
      socials: const [],
      localizationAdmin: LocalizationAdmin.empty(),
      themeAdmin: ThemeAdmin.empty(),
    );
  }
}
