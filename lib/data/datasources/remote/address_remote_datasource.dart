import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../models/address/address_response_model.dart';
import '../../models/address/create_address_request_model.dart';
import '../../models/address/update_address_request_model.dart';

class AddressRemoteDataSource {
  final ApiClient _apiClient;

  AddressRemoteDataSource(this._apiClient);

  /// Get all addresses for a user
  Future<AddressListResponseModel> getAddresses(String userId) async {
    try {
      Logger.info('📍 Fetching addresses for user: $userId');
      
      final response = await _apiClient.get('/users/$userId/addresses');
      
      Logger.info('✅ Addresses fetched successfully');
      return AddressListResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.error('❌ Failed to fetch addresses', e);
      rethrow;
    }
  }

  /// Create a new address
  Future<AddressResponseModel> createAddress(
    String userId,
    CreateAddressRequestModel request,
  ) async {
    try {
      Logger.info('📍 Creating new address for user: $userId');
      
      final response = await _apiClient.post(
        '/users/$userId/addresses',
        data: request.toJson(),
      );
      
      Logger.info('✅ Address created successfully');
      return AddressResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.error('❌ Failed to create address', e);
      rethrow;
    }
  }

  /// Update an existing address
  Future<AddressResponseModel> updateAddress(
    String userId,
    String addressId,
    UpdateAddressRequestModel request,
  ) async {
    try {
      Logger.info('📍 Updating address: $addressId');
      
      final response = await _apiClient.put(
        '/users/$userId/addresses/$addressId',
        data: request.toJson(),
      );
      
      Logger.info('✅ Address updated successfully');
      return AddressResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.error('❌ Failed to update address', e);
      rethrow;
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      Logger.info('📍 Deleting address: $addressId');
      
      await _apiClient.delete('/users/$userId/addresses/$addressId');
      
      Logger.info('✅ Address deleted successfully');
    } catch (e) {
      Logger.error('❌ Failed to delete address', e);
      rethrow;
    }
  }

  /// Set an address as default
  Future<AddressResponseModel> setDefaultAddress(
    String userId,
    String addressId,
  ) async {
    try {
      Logger.info('📍 Setting default address: $addressId');
      
      final response = await _apiClient.put(
        '/users/$userId/addresses/$addressId',
        data: {'isDefault': true},
      );
      
      Logger.info('✅ Default address set successfully');
      return AddressResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.error('❌ Failed to set default address', e);
      rethrow;
    }
  }
}
