class UpdateAddressRequestModel {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final bool? isDefault;

  UpdateAddressRequestModel({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.isDefault,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (street != null) data['street'] = street;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (zipCode != null) data['zipCode'] = zipCode;
    if (country != null) data['country'] = country;
    if (isDefault != null) data['isDefault'] = isDefault;
    
    return data;
  }

  @override
  String toString() {
    return 'UpdateAddressRequestModel(street: $street, city: $city, state: $state, zipCode: $zipCode, country: $country, isDefault: $isDefault)';
  }
}
