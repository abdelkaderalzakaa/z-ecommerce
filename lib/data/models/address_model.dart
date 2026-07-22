class AddressModel {
  final String id;
  final String? label;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  AddressModel({
    String? id,
    this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  AddressModel copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }
}
