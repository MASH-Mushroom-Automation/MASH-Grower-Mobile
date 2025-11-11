class AddressModel {
  final String id;
  final String userId;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String? ?? 'Philippines',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress {
    return '$street, $city, $state $zipCode, $country';
  }

  @override
  String toString() {
    return 'AddressModel(id: $id, street: $street, city: $city, state: $state, isDefault: $isDefault)';
  }
}
