import '../datasources/remote/address_remote_datasource.dart';
import '../models/address/address_response_model.dart';
import '../models/address/create_address_request_model.dart';
import '../models/address/update_address_request_model.dart';

class AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepository(this._remoteDataSource);

  /// Get all addresses for a user
  Future<AddressListResponseModel> getAddresses(String userId) async {
    return await _remoteDataSource.getAddresses(userId);
  }

  /// Create a new address
  Future<AddressResponseModel> createAddress(
    String userId,
    CreateAddressRequestModel request,
  ) async {
    return await _remoteDataSource.createAddress(userId, request);
  }

  /// Update an existing address
  Future<AddressResponseModel> updateAddress(
    String userId,
    String addressId,
    UpdateAddressRequestModel request,
  ) async {
    return await _remoteDataSource.updateAddress(userId, addressId, request);
  }

  /// Delete an address
  Future<void> deleteAddress(String userId, String addressId) async {
    return await _remoteDataSource.deleteAddress(userId, addressId);
  }

  /// Set an address as default
  Future<AddressResponseModel> setDefaultAddress(
    String userId,
    String addressId,
  ) async {
    return await _remoteDataSource.setDefaultAddress(userId, addressId);
  }
}
