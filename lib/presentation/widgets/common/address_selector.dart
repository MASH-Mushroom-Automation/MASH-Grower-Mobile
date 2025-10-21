import 'package:flutter/material.dart';
import '../../../core/models/psgc_models.dart';
import '../../../core/services/psgc_service.dart';

class AddressSelector extends StatefulWidget {
  final Province? selectedProvince;
  final City? selectedCity;
  final Barangay? selectedBarangay;
  final Function(Province?) onProvinceChanged;
  final Function(City?) onCityChanged;
  final Function(Barangay?) onBarangayChanged;

  const AddressSelector({
    super.key,
    this.selectedProvince,
    this.selectedCity,
    this.selectedBarangay,
    required this.onProvinceChanged,
    required this.onCityChanged,
    required this.onBarangayChanged,
  });

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  final PSGCService _psgcService = PSGCService();
  
  List<Province> _provinces = [];
  List<City> _cities = [];
  List<Barangay> _barangays = [];
  
  bool _isLoadingProvinces = false;
  bool _isLoadingCities = false;
  bool _isLoadingBarangays = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);
    try {
      final provinces = await _psgcService.fetchProvinces();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });
    } catch (e) {
      setState(() => _isLoadingProvinces = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading provinces: $e')),
        );
      }
    }
  }

  Future<void> _loadCities(String provinceCode) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _barangays = [];
    });
    
    try {
      final cities = await _psgcService.fetchCitiesByProvince(provinceCode);
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() => _isLoadingCities = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cities: $e')),
        );
      }
    }
  }

  Future<void> _loadBarangays(String cityCode) async {
    setState(() {
      _isLoadingBarangays = true;
      _barangays = [];
    });
    
    try {
      final barangays = await _psgcService.fetchBarangaysByCity(cityCode);
      setState(() {
        _barangays = barangays;
        _isLoadingBarangays = false;
      });
    } catch (e) {
      setState(() => _isLoadingBarangays = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading barangays: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Province Dropdown
        _buildDropdown<Province>(
          label: 'Province',
          value: widget.selectedProvince,
          items: _provinces,
          isLoading: _isLoadingProvinces,
          itemLabel: (province) => province.name,
          onChanged: (province) {
            widget.onProvinceChanged(province);
            widget.onCityChanged(null);
            widget.onBarangayChanged(null);
            if (province != null) {
              _loadCities(province.code);
            } else {
              setState(() {
                _cities = [];
                _barangays = [];
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // City/Municipality Dropdown
        _buildDropdown<City>(
          label: 'City / Municipality',
          value: widget.selectedCity,
          items: _cities,
          isLoading: _isLoadingCities,
          itemLabel: (city) => city.name,
          enabled: widget.selectedProvince != null,
          onChanged: (city) {
            widget.onCityChanged(city);
            widget.onBarangayChanged(null);
            if (city != null) {
              _loadBarangays(city.code);
            } else {
              setState(() {
                _barangays = [];
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Barangay Dropdown
        _buildDropdown<Barangay>(
          label: 'Barangay',
          value: widget.selectedBarangay,
          items: _barangays,
          isLoading: _isLoadingBarangays,
          itemLabel: (barangay) => barangay.name,
          enabled: widget.selectedCity != null,
          onChanged: (barangay) {
            widget.onBarangayChanged(barangay);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required bool isLoading,
    required String Function(T) itemLabel,
    required Function(T?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D5F4C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5F4C)),
                      ),
                    ),
                  ),
                )
              : DropdownButton<T>(
                  value: value,
                  hint: Text(
                    'Select $label',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  dropdownColor: Colors.white,
                  items: items.isEmpty
                      ? null
                      : items.map((item) {
                          return DropdownMenuItem<T>(
                            value: item,
                            child: Text(
                              itemLabel(item),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                  onChanged: enabled ? onChanged : null,
                ),
        ),
      ],
    );
  }
}
