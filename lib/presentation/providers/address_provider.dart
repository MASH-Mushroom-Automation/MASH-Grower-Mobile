import 'package:flutter/material.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/remote/address_remote_datasource.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/models/address/address_model.dart';
import '../../data/models/address/create_address_request_model.dart';
import '../../data/models/address/update_address_request_model.dart';
import '../../core/utils/logger.dart';

class AddressProvider extends ChangeNotifier {
  late final AddressRepository _addressRepository;
  
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _error;
  
  AddressProvider() {
    _initializeRepository();
  }
  
  void _initializeRepository() {
    final dioClient = DioClient();
    final apiClient = ApiClient(dioClient);
    final remoteDataSource = AddressRemoteDataSource(apiClient);
    _addressRepository = AddressRepository(remoteDataSource);
  }
  
  // Getters
  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
  
  bool get hasAddresses => _addresses.isNotEmpty;
  
  /// Load all addresses for a user
  Future<void> loadAddresses(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📍 Loading addresses for user: $userId');
      
      final response = await _addressRepository.getAddresses(userId);
      
      if (response.success) {
        _addresses = response.addresses;
        Logger.info('✅ Loaded ${_addresses.length} addresses');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      Logger.error('❌ Failed to load addresses', e);
      _setError('Failed to load addresses. Please try again.');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Create a new address
  Future<bool> createAddress(
    String userId,
    CreateAddressRequestModel request,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📍 Creating new address');
      
      final response = await _addressRepository.createAddress(userId, request);
      
      if (response.success && response.address != null) {
        _addresses.add(response.address!);
        
        // If this is the first address or marked as default, update other addresses
        if (response.address!.isDefault) {
          _updateDefaultAddress(response.address!.id);
        }
        
        notifyListeners();
        Logger.info('✅ Address created successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      Logger.error('❌ Failed to create address', e);
      _setError('Failed to create address. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update an existing address
  Future<bool> updateAddress(
    String userId,
    String addressId,
    UpdateAddressRequestModel request,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📍 Updating address: $addressId');
      
      final response = await _addressRepository.updateAddress(
        userId,
        addressId,
        request,
      );
      
      if (response.success && response.address != null) {
        final index = _addresses.indexWhere((a) => a.id == addressId);
        if (index != -1) {
          _addresses[index] = response.address!;
          
          // If marked as default, update other addresses
          if (response.address!.isDefault) {
            _updateDefaultAddress(response.address!.id);
          }
          
          notifyListeners();
        }
        Logger.info('✅ Address updated successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      Logger.error('❌ Failed to update address', e);
      _setError('Failed to update address. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Delete an address
  Future<bool> deleteAddress(String userId, String addressId) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📍 Deleting address: $addressId');
      
      await _addressRepository.deleteAddress(userId, addressId);
      
      _addresses.removeWhere((a) => a.id == addressId);
      notifyListeners();
      
      Logger.info('✅ Address deleted successfully');
      return true;
    } catch (e) {
      Logger.error('❌ Failed to delete address', e);
      _setError('Failed to delete address. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Set an address as default
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.info('📍 Setting default address: $addressId');
      
      final response = await _addressRepository.setDefaultAddress(
        userId,
        addressId,
      );
      
      if (response.success && response.address != null) {
        _updateDefaultAddress(addressId);
        notifyListeners();
        
        Logger.info('✅ Default address set successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      Logger.error('❌ Failed to set default address', e);
      _setError('Failed to set default address. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update local state to reflect new default address
  void _updateDefaultAddress(String newDefaultId) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == newDefaultId,
      );
    }
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  /// Clear all addresses (useful for logout)
  void clear() {
    _addresses = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
