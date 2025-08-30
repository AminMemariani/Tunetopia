# Hive Database Implementation

This directory contains the Hive database implementation for storing songs and theme preferences locally in the Tunetopia music player.

## Files

### `app_database.dart`
The main database service that manages all database initializations and provides a unified interface.

### `song_database.dart`
The database service that handles all Hive operations for songs.

#### Key Features:
- **Initialize**: Sets up Hive and opens the songs box
- **CRUD Operations**: Add, update, remove, and retrieve songs
- **Duplicate Prevention**: Checks for existing songs by file path
- **Batch Operations**: Add multiple songs at once
- **Query Methods**: Find songs by file path or check existence

#### Usage:
```dart
// Initialize the database
await SongDatabase.initialize();

// Add a song
await SongDatabase.addSong(song);

// Get all songs
List<Song> songs = SongDatabase.getAllSongs();

// Check if song exists
bool exists = SongDatabase.songExists(filePath);

// Update song metadata
await SongDatabase.updateSong(song);

// Remove a song
await SongDatabase.removeSong(song);
```

### `theme_database.dart`
The database service that handles all Hive operations for theme preferences.

#### Key Features:
- **Initialize**: Opens the theme preferences box
- **Save Theme**: Stores user's theme preference (light/dark mode)
- **Load Theme**: Retrieves saved theme preference
- **Check Preference**: Verifies if theme preference exists
- **Clear Preference**: Removes saved theme preference

#### Usage:
```dart
// Save theme preference
await ThemeDatabase.saveThemeMode(true); // true for dark mode

// Load theme preference
bool isDarkMode = ThemeDatabase.loadThemeMode();

// Check if preference exists
bool hasPreference = ThemeDatabase.hasThemePreference();

// Clear preference
await ThemeDatabase.clearThemePreference();
```

## Integration with Providers

### Songs Provider
The `Songs` provider in `lib/providers/songs.dart` has been updated to:
- Initialize the database on app startup
- Load existing songs from the database
- Save new songs to the database when imported
- Update song metadata in the database when loaded

### Theme Provider
The `ThemeProvider` in `lib/theme/theme_provider.dart` has been updated to:
- Load saved theme preference on app startup
- Save theme preference when user changes theme
- Provide theme state management with persistence

## Song Model Changes

The `Song` model in `lib/models/song.dart` has been updated to:
- Use Hive annotations for persistence
- Store duration as seconds (int) for Hive compatibility
- Provide getter/setter for Duration conversion
- Include generated Hive adapter code

## Benefits

1. **Persistence**: Songs and theme preferences are remembered between app sessions
2. **Performance**: Fast local storage with Hive
3. **Metadata Caching**: Song metadata is cached locally
4. **Duplicate Prevention**: Prevents importing the same song multiple times
5. **Offline Support**: Songs work without internet connection
6. **Theme Persistence**: User's theme preference is saved and restored automatically

## Setup

The databases are automatically initialized when the app starts in `main.dart`. The `AppDatabase` service manages all database initializations, while individual providers handle their specific database operations transparently.
