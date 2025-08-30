import 'package:flutter/material.dart';
import 'package:music_player/theme/theme.dart';
import 'package:music_player/data/theme_database.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  bool _isInitialized = false;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveThemePreference();
    notifyListeners();
  }

  // Initialize theme from saved preference
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final isDarkMode = ThemeDatabase.loadThemeMode();
      
      _themeData = isDarkMode ? darkMode : lightMode;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      // Fallback to light mode if there's an error
      _themeData = lightMode;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    _saveThemePreference();
    notifyListeners();
  }

  // Save theme preference to database
  Future<void> _saveThemePreference() async {
    try {
      final isDarkMode = _themeData == darkMode;
      await ThemeDatabase.saveThemeMode(isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Get current theme mode as string
  String get currentThemeMode {
    return _themeData == darkMode ? 'dark' : 'light';
  }

  // Check if current theme is dark mode
  bool get isDarkMode {
    return _themeData == darkMode;
  }
}
