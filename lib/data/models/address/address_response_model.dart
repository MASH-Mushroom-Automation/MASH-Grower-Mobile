import 'address_model.dart';

class AddressResponseModel {
  final bool success;
  final AddressModel? address;
  final String message;

  AddressResponseModel({
    required this.success,
    this.address,
    this.message = '',
  });

  factory AddressResponseModel.fromJson(Map<String, dynamic> json) {
    return AddressResponseModel(
      success: json['success'] as bool? ?? false,
      address: json['data'] != null 
          ? AddressModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String? ?? '',
    );
  }
}

class AddressListResponseModel {
  final bool success;
  final List<AddressModel> addresses;
  final String message;

  AddressListResponseModel({
    required this.success,
    required this.addresses,
    this.message = '',
  });

  factory AddressListResponseModel.fromJson(Map<String, dynamic> json) {
    return AddressListResponseModel(
      success: json['success'] as bool? ?? false,
      addresses: json['data'] != null
          ? (json['data'] as List)
              .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      message: json['message'] as String? ?? '',
    );
  }
}
