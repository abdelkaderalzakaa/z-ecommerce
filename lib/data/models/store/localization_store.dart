import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

class LocalizationStore {
  final LocalizedString name;
  final LocalizedString slogan;
  final LocalizedString description;
  final LocalizedString footerDescription;
  final LocalizedString aboutUs;
  final LocalizedString termsAndConditions;
  final LocalizedString privacyPolicy;

  LocalizationStore({
    required this.name,
    required this.slogan,
    required this.description,
    required this.footerDescription,
    required this.aboutUs,
    required this.termsAndConditions,
    required this.privacyPolicy,
  });

  factory LocalizationStore.fromMap(Map<String, dynamic> map) {
    return LocalizationStore(
      name: map['name'] != null ? LocalizedString.fromJson(map['name']) : const LocalizedString(ar: '', en: ''),
      slogan: map['slogan'] != null ? LocalizedString.fromJson(map['slogan']) : const LocalizedString(ar: '', en: ''),
      description: map['description'] != null ? LocalizedString.fromJson(map['description']) : const LocalizedString(ar: '', en: ''),
      footerDescription: map['footerDescription'] != null ? LocalizedString.fromJson(map['footerDescription']) : const LocalizedString(ar: '', en: ''),
      aboutUs: map['aboutUs'] != null ? LocalizedString.fromJson(map['aboutUs']) : const LocalizedString(ar: '', en: ''),
      termsAndConditions: map['termsAndConditions'] != null ? LocalizedString.fromJson(map['termsAndConditions']) : const LocalizedString(ar: '', en: ''),
      privacyPolicy: map['privacyPolicy'] != null ? LocalizedString.fromJson(map['privacyPolicy']) : const LocalizedString(ar: '', en: ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.toJson(),
      'slogan': slogan.toJson(),
      'description': description.toJson(),
      'footerDescription': footerDescription.toJson(),
      'aboutUs': aboutUs.toJson(),
      'termsAndConditions': termsAndConditions.toJson(),
      'privacyPolicy': privacyPolicy.toJson(),
    };
  }
}
