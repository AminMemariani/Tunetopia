import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/song_database.dart';
import 'package:music_player/data/theme_database.dart';

class AppDatabase {
  static bool _isInitialized = false;
  
  // Initialize all databases
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Initialize all database services
      await SongDatabase.initialize();
      await ThemeDatabase.initialize();
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize databases: $e');
    }
  }
  
  // Close all databases
  static Future<void> close() async {
    try {
      await SongDatabase.close();
      await ThemeDatabase.close();
      _isInitialized = false;
    } catch (e) {
      throw Exception('Failed to close databases: $e');
    }
  }
  
  // Check if databases are initialized
  static bool get isInitialized => _isInitialized;
}
