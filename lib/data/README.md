# Hive Database Implementation

This directory contains the Hive database implementation for storing songs locally in the Tunetopia music player.

## Files

### `song_database.dart`
The main database service that handles all Hive operations for songs.

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

## Integration with Provider

The `Songs` provider in `lib/providers/songs.dart` has been updated to:
- Initialize the database on app startup
- Load existing songs from the database
- Save new songs to the database when imported
- Update song metadata in the database when loaded

## Song Model Changes

The `Song` model in `lib/models/song.dart` has been updated to:
- Use Hive annotations for persistence
- Store duration as seconds (int) for Hive compatibility
- Provide getter/setter for Duration conversion
- Include generated Hive adapter code

## Benefits

1. **Persistence**: Songs are remembered between app sessions
2. **Performance**: Fast local storage with Hive
3. **Metadata Caching**: Song metadata is cached locally
4. **Duplicate Prevention**: Prevents importing the same song multiple times
5. **Offline Support**: Songs work without internet connection

## Setup

The database is automatically initialized when the app starts in `main.dart`. The `Songs` provider handles all database operations transparently.
