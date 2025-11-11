import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/address/address_model.dart';
import '../../../data/models/address/create_address_request_model.dart';
import '../../../data/models/address/update_address_request_model.dart';
import '../../../core/models/psgc_models.dart';
import '../../widgets/common/address_selector.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  
  Region? _selectedRegion;
  Province? _selectedProvince;
  City? _selectedCity;
  Barangay? _selectedBarangay;
  bool _isDefault = false;
  bool _isLoading = false;

  bool get _isEditMode => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingAddress();
    }
  }

  void _loadExistingAddress() {
    final address = widget.address!;
    _streetController.text = address.street;
    _isDefault = address.isDefault;
    
    // Note: We can't restore Province/City/Barangay objects from just names
    // User will need to reselect them if they want to change
  }

  @override
  void dispose() {
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate address selection
    if (_selectedRegion == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select region and city'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final addressProvider = context.read<AddressProvider>();
    final userId = authProvider.user?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    bool success;

    // For NCR, use region name as state; otherwise use province name
    final stateName = _selectedProvince?.name ?? _selectedRegion!.name;

    if (_isEditMode) {
      // Update existing address
      final request = UpdateAddressRequestModel(
        street: _streetController.text.trim(),
        city: _selectedCity!.name,
        state: stateName,
        zipCode: '0000',
        country: 'Philippines',
        isDefault: _isDefault,
      );

      success = await addressProvider.updateAddress(
        userId,
        widget.address!.id,
        request,
      );
    } else {
      // Create new address
      final request = CreateAddressRequestModel(
        street: _streetController.text.trim(),
        city: _selectedCity!.name,
        state: stateName,
        zipCode: '0000',
        country: 'Philippines',
        isDefault: _isDefault,
      );

      success = await addressProvider.createAddress(userId, request);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted && addressProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(addressProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5F4C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Address' : 'Add Address',
          style: const TextStyle(
            color: Color(0xFF2D5F4C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F4C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AddressSelector(
                      selectedRegion: _selectedRegion,
                      selectedProvince: _selectedProvince,
                      selectedCity: _selectedCity,
                      selectedBarangay: _selectedBarangay,
                      onRegionChanged: (region) {
                        setState(() {
                          _selectedRegion = region;
                          _selectedProvince = null;
                          _selectedCity = null;
                          _selectedBarangay = null;
                        });
                      },
                      onProvinceChanged: (province) {
                        setState(() {
                          _selectedProvince = province;
                          _selectedCity = null;
                          _selectedBarangay = null;
                        });
                      },
                      onCityChanged: (city) {
                        setState(() {
                          _selectedCity = city;
                          _selectedBarangay = null;
                        });
                      },
                      onBarangayChanged: (barangay) {
                        setState(() {
                          _selectedBarangay = barangay;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Street Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5F4C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _streetController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g., 123 Main St, Bldg 5, Unit 3A',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Color(0xFF2D5F4C), width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter street address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Set as default address',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'This address will be used for orders by default',
                  style: TextStyle(fontSize: 13),
                ),
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value ?? false);
                },
                activeColor: const Color(0xFF2D5F4C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5F4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Address' : 'Save Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
