import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/psgc_models.dart';

class PSGCService {
  static const String _baseUrl = 'https://psgc.gitlab.io/api';
  
  // Cache to avoid repeated API calls
  static List<Province>? _cachedProvinces;
  static List<City>? _cachedCities;
  static List<Barangay>? _cachedBarangays;

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
    _cachedProvinces = null;
    _cachedCities = null;
    _cachedBarangays = null;
  }
}
