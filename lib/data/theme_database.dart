import 'package:hive_flutter/hive_flutter.dart';

class ThemeDatabase {
  static const String _boxName = 'theme_box';
  static const String _themeKey = 'theme_mode';
  static Box? _box;
  
  // Initialize Hive and open the theme box
  static Future<void> initialize() async {
    if (_box != null) return; // Already initialized
    
    // Open the theme box
    _box = await Hive.openBox(_boxName);
  }
  
  // Save theme preference to database
  static Future<void> saveThemeMode(bool isDarkMode) async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    
    await _box!.put(_themeKey, isDarkMode);
  }
  
  // Load theme preference from database
  static bool loadThemeMode() {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    
    return _box!.get(_themeKey, defaultValue: false);
  }
  
  // Check if theme preference exists
  static bool hasThemePreference() {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    
    return _box!.containsKey(_themeKey);
  }
  
  // Clear theme preference
  static Future<void> clearThemePreference() async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    
    await _box!.delete(_themeKey);
  }
  
  // Close the database
  static Future<void> close() async {
    if (_box != null) {
      await _box!.close();
      _box = null;
    }
  }
}
