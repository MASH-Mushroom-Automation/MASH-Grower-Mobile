import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/psgc_models.dart';

class PSGCService {
  static const String _baseUrl = 'https://psgc.gitlab.io/api';
  
  // Cache to avoid repeated API calls
  static List<Region>? _cachedRegions;
  static List<Province>? _cachedProvinces;
  static List<City>? _cachedCities;
  static List<Barangay>? _cachedBarangays;

  /// Fetch all regions
  Future<List<Region>> fetchRegions() async {
    if (_cachedRegions != null) {
      return _cachedRegions!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/regions.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedRegions = data.map((json) => Region.fromJson(json)).toList();
        
        // Sort alphabetically
        _cachedRegions!.sort((a, b) => a.name.compareTo(b.name));
        
        return _cachedRegions!;
      } else {
        throw Exception('Failed to load regions');
      }
    } catch (e) {
      throw Exception('Error fetching regions: $e');
    }
  }

  /// Fetch all provinces
  Future<List<Province>> fetchProvinces() async {
    if (_cachedProvinces != null) {
      return _cachedProvinces!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/provinces.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedProvinces = data.map((json) => Province.fromJson(json)).toList();
        
        // Sort alphabetically
        _cachedProvinces!.sort((a, b) => a.name.compareTo(b.name));
        
        return _cachedProvinces!;
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  /// Fetch provinces by region code
  Future<List<Province>> fetchProvincesByRegion(String regionCode) async {
    final allProvinces = await fetchProvinces();
    
    final filteredProvinces = allProvinces
        .where((province) => province.regionCode == regionCode)
        .toList();
    
    // Sort alphabetically
    filteredProvinces.sort((a, b) => a.name.compareTo(b.name));
    
    return filteredProvinces;
  }

  /// Fetch cities by region code (for NCR which has no provinces)
  Future<List<City>> fetchCitiesByRegion(String regionCode) async {
    final allCities = await fetchAllCities();
    
    // Debug: Print some info
    print('fetchCitiesByRegion called with regionCode: $regionCode');
    print('Total cities loaded: ${allCities.length}');
    
    // For NCR, try different approaches to find cities
    if (regionCode == '130000000') {
      // Try multiple patterns for NCR cities
      var filteredCities = allCities
          .where((city) => city.provinceCode.startsWith('13'))
          .toList();
      
      print('NCR cities found with "13" prefix: ${filteredCities.length}');
      
      // If no cities found with "13" prefix, try other patterns
      if (filteredCities.isEmpty) {
        // Try looking for cities with specific NCR province codes
        final ncrProvinceCodes = ['137300000', '137400000', '137500000', '137600000']; // Common NCR codes
        filteredCities = allCities
            .where((city) => ncrProvinceCodes.contains(city.provinceCode))
            .toList();
        
        print('NCR cities found with specific codes: ${filteredCities.length}');
      }
      
      // If still no cities, return all cities for debugging
      if (filteredCities.isEmpty) {
        print('No NCR cities found, returning first 10 cities for debugging');
        filteredCities = allCities.take(10).toList();
      }
      
      // Sort alphabetically
      filteredCities.sort((a, b) => a.name.compareTo(b.name));
      
      return filteredCities;
    } else {
      // For other regions, get provinces first then filter cities
      final allProvinces = await fetchProvinces();
      
      // Get all province codes for this region
      final provinceCodesInRegion = allProvinces
          .where((province) => province.regionCode == regionCode)
          .map((province) => province.code)
          .toSet();
      
      final filteredCities = allCities
          .where((city) => provinceCodesInRegion.contains(city.provinceCode))
          .toList();
      
      // Sort alphabetically
      filteredCities.sort((a, b) => a.name.compareTo(b.name));
      
      return filteredCities;
    }
  }

  /// Fetch all cities/municipalities
  Future<List<City>> fetchAllCities() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cities-municipalities.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedCities = data.map((json) => City.fromJson(json)).toList();
        return _cachedCities!;
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  /// Fetch cities by province code
  Future<List<City>> fetchCitiesByProvince(String provinceCode) async {
    final allCities = await fetchAllCities();
    
    final filteredCities = allCities
        .where((city) => city.provinceCode == provinceCode)
        .toList();
    
    // Sort alphabetically
    filteredCities.sort((a, b) => a.name.compareTo(b.name));
    
    return filteredCities;
  }

  /// Fetch all barangays
  Future<List<Barangay>> fetchAllBarangays() async {
    if (_cachedBarangays != null) {
      return _cachedBarangays!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/barangays.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedBarangays = data.map((json) => Barangay.fromJson(json)).toList();
        return _cachedBarangays!;
      } else {
        throw Exception('Failed to load barangays');
      }
    } catch (e) {
      throw Exception('Error fetching barangays: $e');
    }
  }

  /// Fetch barangays by city code
  Future<List<Barangay>> fetchBarangaysByCity(String cityCode) async {
    final allBarangays = await fetchAllBarangays();
    
    final filteredBarangays = allBarangays
        .where((barangay) => barangay.cityCode == cityCode)
        .toList();
    
    // Sort alphabetically
    filteredBarangays.sort((a, b) => a.name.compareTo(b.name));
    
    return filteredBarangays;
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _cachedRegions = null;
    _cachedProvinces = null;
    _cachedCities = null;
    _cachedBarangays = null;
  }
}
