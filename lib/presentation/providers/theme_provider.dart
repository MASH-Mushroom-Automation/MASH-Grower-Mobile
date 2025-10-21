import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/utils/logger.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(StorageKeys.themeMode);
      
      if (themeModeString != null) {
        switch (themeModeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        Logger.info('Loaded theme mode: ${_themeMode.name}');
      }
    } catch (e) {
      Logger.error('Failed to load theme mode: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.themeMode, mode.name);
      
      Logger.info('Theme mode changed to: ${mode.name}');
    } catch (e) {
      Logger.error('Failed to save theme mode: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
