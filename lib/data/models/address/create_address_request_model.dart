class CreateAddressRequestModel {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  CreateAddressRequestModel({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'Philippines',
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  @override
  String toString() {
    return 'CreateAddressRequestModel(street: $street, city: $city, state: $state, zipCode: $zipCode, country: $country, isDefault: $isDefault)';
  }
}
