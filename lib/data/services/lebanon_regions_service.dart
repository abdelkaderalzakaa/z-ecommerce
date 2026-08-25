import 'dart:convert';
import 'package:flutter/services.dart';

class LebanonTown {
  final String name;
  LebanonTown({required this.name});
}

class LebanonDistrict {
  final int id;
  final String nameAr;
  final String nameEn;
  final List<String> towns;

  LebanonDistrict({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.towns,
  });

  factory LebanonDistrict.fromMap(Map<String, dynamic> map) {
    return LebanonDistrict(
      id: map['id'] ?? 0,
      nameAr: map['name_ar'] ?? '',
      nameEn: map['name_en'] ?? '',
      towns: List<String>.from(map['towns'] ?? []),
    );
  }

  String getName(bool isAr) => isAr ? nameAr : nameEn;
}

class LebanonGovernorate {
  final int id;
  final String nameAr;
  final String nameEn;
  final List<LebanonDistrict> districts;

  LebanonGovernorate({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.districts,
  });

  factory LebanonGovernorate.fromMap(Map<String, dynamic> map) {
    return LebanonGovernorate(
      id: map['id'] ?? 0,
      nameAr: map['name_ar'] ?? '',
      nameEn: map['name_en'] ?? '',
      districts: (map['districts'] as List<dynamic>? ?? [])
          .map((d) => LebanonDistrict.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }

  String getName(bool isAr) => isAr ? nameAr : nameEn;
}

class LebanonRegionsService {
  static List<LebanonGovernorate> _governorates = [];
  static bool _isLoaded = false;

  Future<List<LebanonGovernorate>> loadRegions() => getGovernorates();

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/json/country_lebanon.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final list = data['governorates'] as List<dynamic>? ?? [];
      _governorates = list
          .map((g) => LebanonGovernorate.fromMap(g as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      _governorates = [];
    }
  }

  static Future<List<LebanonGovernorate>> getGovernorates() async {
    if (!_isLoaded) await init();
    return _governorates;
  }

  static LebanonGovernorate? findGovernorate(String name) {
    for (final gov in _governorates) {
      if (gov.nameAr == name || gov.nameEn.toLowerCase() == name.toLowerCase()) {
        return gov;
      }
    }
    return null;
  }

  static LebanonDistrict? findDistrict(String name) {
    for (final gov in _governorates) {
      for (final dist in gov.districts) {
        if (dist.nameAr == name || dist.nameEn.toLowerCase() == name.toLowerCase()) {
          return dist;
        }
      }
    }
    return null;
  }
}
