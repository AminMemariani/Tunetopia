import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/data/theme_database.dart';

void main() {
  group('ThemeDatabase Tests', () {
    setUpAll(() async {
      // Initialize the database for testing
      await ThemeDatabase.initialize();
    });

    tearDownAll(() async {
      // Clean up after tests
      await ThemeDatabase.close();
    });

    test('should save and load theme mode correctly', () async {
      // Test saving dark mode
      await ThemeDatabase.saveThemeMode(true);
      expect(ThemeDatabase.loadThemeMode(), true);

      // Test saving light mode
      await ThemeDatabase.saveThemeMode(false);
      expect(ThemeDatabase.loadThemeMode(), false);
    });

    test('should return false as default when no preference is set', () {
      // Clear any existing preference
      ThemeDatabase.clearThemePreference();

      // Should return false (light mode) as default
      expect(ThemeDatabase.loadThemeMode(), false);
    });

    test('should check if theme preference exists', () async {
      // Clear preference first
      await ThemeDatabase.clearThemePreference();
      expect(ThemeDatabase.hasThemePreference(), false);

      // Save a preference
      await ThemeDatabase.saveThemeMode(true);
      expect(ThemeDatabase.hasThemePreference(), true);
    });

    test('should clear theme preference', () async {
      // Save a preference first
      await ThemeDatabase.saveThemeMode(true);
      expect(ThemeDatabase.hasThemePreference(), true);

      // Clear the preference
      await ThemeDatabase.clearThemePreference();
      expect(ThemeDatabase.hasThemePreference(), false);
      expect(ThemeDatabase.loadThemeMode(), false); // Should return default
    });
  });
}
