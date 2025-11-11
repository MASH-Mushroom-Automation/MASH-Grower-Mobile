import 'package:flutter/material.dart';
import '../../../core/models/psgc_models.dart';
import '../../../core/services/psgc_service.dart';

class AddressSelector extends StatefulWidget {
  final Region? selectedRegion;
  final Province? selectedProvince;
  final City? selectedCity;
  final Barangay? selectedBarangay;
  final Function(Region?) onRegionChanged;
  final Function(Province?) onProvinceChanged;
  final Function(City?) onCityChanged;
  final Function(Barangay?) onBarangayChanged;

  const AddressSelector({
    super.key,
    this.selectedRegion,
    this.selectedProvince,
    this.selectedCity,
    this.selectedBarangay,
    required this.onRegionChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
    required this.onBarangayChanged,
  });

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  final PSGCService _psgcService = PSGCService();
  
  List<Region> _regions = [];
  List<Province> _provinces = [];
  List<City> _cities = [];
  List<Barangay> _barangays = [];
  
  bool _isLoadingRegions = false;
  bool _isLoadingProvinces = false;
  bool _isLoadingCities = false;
  bool _isLoadingBarangays = false;

  // NCR region code
  static const String _ncrRegionCode = '130000000';

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  bool get _isNCR => widget.selectedRegion?.code == _ncrRegionCode;

  Future<void> _loadRegions() async {
    setState(() => _isLoadingRegions = true);
    try {
      final regions = await _psgcService.fetchRegions();
      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
    } catch (e) {
      setState(() => _isLoadingRegions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading regions: $e')),
        );
      }
    }
  }

  Future<void> _loadProvinces(String regionCode) async {
    setState(() {
      _isLoadingProvinces = true;
      _provinces = [];
      _cities = [];
      _barangays = [];
    });
    
    try {
      final provinces = await _psgcService.fetchProvincesByRegion(regionCode);
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

  Future<void> _loadCities(String? provinceCode, String? regionCode) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _barangays = [];
    });
    
    try {
      List<City> cities;
      if (regionCode == _ncrRegionCode && regionCode != null) {
        // For NCR, load cities directly by region
        cities = await _psgcService.fetchCitiesByRegion(regionCode);
      } else if (provinceCode != null) {
        // For other regions, load cities by province
        cities = await _psgcService.fetchCitiesByProvince(provinceCode);
      } else {
        cities = [];
      }
      
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
        // Region Dropdown
        _buildDropdown<Region>(
          label: 'Region',
          value: widget.selectedRegion,
          items: _regions,
          isLoading: _isLoadingRegions,
          itemLabel: (region) => region.name,
          onChanged: (region) {
            widget.onRegionChanged(region);
            widget.onProvinceChanged(null);
            widget.onCityChanged(null);
            widget.onBarangayChanged(null);
            if (region != null) {
              if (region.code == _ncrRegionCode) {
                // For NCR, load cities directly
                _loadCities(null, region.code);
              } else {
                // For other regions, load provinces first
                _loadProvinces(region.code);
              }
            } else {
              setState(() {
                _provinces = [];
                _cities = [];
                _barangays = [];
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Province Dropdown (hidden for NCR)
        if (!_isNCR) ...[
          _buildDropdown<Province>(
            label: 'Province',
            value: widget.selectedProvince,
            items: _provinces,
            isLoading: _isLoadingProvinces,
            itemLabel: (province) => province.name,
            enabled: widget.selectedRegion != null,
            onChanged: (province) {
              widget.onProvinceChanged(province);
              widget.onCityChanged(null);
              widget.onBarangayChanged(null);
              if (province != null) {
                _loadCities(province.code, null);
              } else {
                setState(() {
                  _cities = [];
                  _barangays = [];
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],

        // City/Municipality Dropdown
        _buildDropdown<City>(
          label: 'City / Municipality',
          value: widget.selectedCity,
          items: _cities,
          isLoading: _isLoadingCities,
          itemLabel: (city) => city.name,
          enabled: _isNCR ? widget.selectedRegion != null : widget.selectedProvince != null,
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
