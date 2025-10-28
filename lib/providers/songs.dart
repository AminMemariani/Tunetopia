import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/data/song_database.dart';

class Songs with ChangeNotifier {
  final List<Song> _songs = [];
  bool _isInitialized = false;

  String _sanitizeFilePath(String input) {
    final marker = ', name:';
    final idx = input.indexOf(marker);
    final trimmed = idx != -1 ? input.substring(0, idx) : input;
    return trimmed.trim();
  }

  // Initialize the provider and load songs from database
  Future<void> initialize() async {
    if (!_isInitialized) {
      await SongDatabase.initialize();
      await loadSongsFromDatabase();
      // Clean up any songs that no longer exist on the device
      await cleanupMissingFiles();
      _isInitialized = true;
    }
  }

  Song? findByName(String name) {
    return _songs.firstWhere((sng) => sng.songName == name);
  }

  List<Song> get songs {
    return [..._songs];
  }

  // Load songs from the database
  Future<void> loadSongsFromDatabase() async {
    try {
      final songsFromDb = SongDatabase.getAllSongs();
      _songs.clear();
      _songs.addAll(songsFromDb);
      notifyListeners();
      
      // Load metadata for songs that don't have duration
      await _loadMissingMetadata();
    } catch (e) {
      debugPrint("Error loading songs from database: $e");
    }
  }

  // Load metadata for songs that don't have duration information
  Future<void> _loadMissingMetadata() async {
    final songsWithoutDuration =
        _songs.where((song) => song.duration == null).toList();

    for (final song in songsWithoutDuration) {
      try {
        await loadImage(song);
      } catch (e) {
        debugPrint("Error loading metadata for ${song.songName}: $e");
      }
    }
  }

  // Refresh metadata for all songs (useful for debugging)
  Future<void> refreshAllMetadata() async {
    for (final song in _songs) {
      try {
        await loadImage(song);
      } catch (e) {
        debugPrint("Error refreshing metadata for ${song.songName}: $e");
      }
    }
  }

  // Clear all songs from database and memory (useful for debugging)
  Future<void> clearAllSongs() async {
    try {
      await SongDatabase.clearAllSongs();
      _songs.clear();
      notifyListeners();
      debugPrint("Cleared all songs from database and memory");
    } catch (e) {
      debugPrint("Error clearing songs: $e");
    }
  }

  // Clean up songs that no longer exist on the device
  Future<void> cleanupMissingFiles() async {
    List<Song> songsToRemove = [];

    for (final song in _songs) {
      try {
        if (song.filePath == null || song.filePath!.isEmpty) {
          debugPrint(
              "Removing song with null/empty file path: ${song.songName}");
          songsToRemove.add(song);
          continue;
        }

        // Fix corrupted paths persisted earlier (contain appended metadata)
        if (song.filePath!.contains(', name:')) {
          final corrected = _sanitizeFilePath(song.filePath!);
          if (corrected != song.filePath) {
            song.filePath = corrected;
            await SongDatabase.updateSong(song);
          }
        }

        final file = File(song.filePath!);
        debugPrint("Cleanup checking file: '${song.filePath}'");
        if (!await file.exists()) {
          debugPrint("Removing missing file from library: ${song.songName}");
          songsToRemove.add(song);
        } else {
          debugPrint("File exists, keeping in library: ${song.songName}");
        }
      } catch (e) {
        debugPrint("Error checking file existence for ${song.songName}: $e");
        songsToRemove.add(song);
      }
    }

    // Remove missing songs from memory and database
    for (final song in songsToRemove) {
      await removeSongFromLibrary(song);
    }

    if (songsToRemove.isNotEmpty) {
      debugPrint("Removed ${songsToRemove.length} missing songs from library");
    }
  }

  // Remove a song from the library (both memory and database)
  Future<void> removeSongFromLibrary(Song song) async {
    try {
      // Remove from database
      await SongDatabase.removeSong(song);

      // Remove from memory
      _songs.removeWhere((s) => s.filePath == song.filePath);

      notifyListeners();
    } catch (e) {
      debugPrint("Error removing song from library: $e");
    }
  }

  Future<void> addSongs(String files) async {
    RegExp regex = RegExp(r"PlatformFile\(path ([^)]*)");

    Iterable<Match?> matches = regex.allMatches(files);

    if (matches.isNotEmpty) {
      List<Song> newSongs = [];
      
      for (Match? match in matches) {
        final rawPath = match!.group(1)!.trim();
        final filePath = _sanitizeFilePath(rawPath);
        final songName = filePath.split('/').last;

        // Check if song already exists in database
        if (!SongDatabase.songExists(filePath)) {
          final song = Song(
            songName: songName,
            filePath: filePath,
          );

          newSongs.add(song);
          _songs.add(song);
        }
      }
      
      // Save new songs to database
      if (newSongs.isNotEmpty) {
        await SongDatabase.addSongs(newSongs);
        notifyListeners();
        
        // Load metadata for newly added songs
        for (final song in newSongs) {
          try {
            await loadImage(song);
          } catch (e) {
            debugPrint("Error loading metadata for ${song.songName}: $e");
          }
        }
      }
    } else {
      debugPrint("Filename not found.");
    }
  }

  Future<void> loadImage(Song song) async {
    try {
      // Check if file path is valid
      if (song.filePath == null || song.filePath!.isEmpty) {
        debugPrint("Song has null or empty file path");
        song.songImage = null;
        song.notifyListeners();
        return;
      }

      // Sanitize path on-the-fly if needed and persist
      if (song.filePath!.contains(', name:')) {
        final corrected = _sanitizeFilePath(song.filePath!);
        if (corrected != song.filePath) {
          song.filePath = corrected;
          await SongDatabase.updateSong(song);
        }
      }

      // Check if file exists before trying to read metadata
      final file = File(song.filePath!);
      debugPrint("Checking file existence for: '${song.filePath}'");
      debugPrint("File path length: ${song.filePath!.length}");
      debugPrint("File path bytes: ${song.filePath!.codeUnits}");

      if (!await file.exists()) {
        debugPrint("File does not exist: ${song.filePath}");
        // Try to check if the file exists with a different approach
        final file2 = File(song.filePath!.trim());
        if (await file2.exists()) {
          debugPrint("File exists after trimming: ${song.filePath!.trim()}");
          // Update the song with the trimmed path
          song.filePath = song.filePath!.trim();
          // Retry with the corrected path
          final correctedFile = File(song.filePath!);
          if (await correctedFile.exists()) {
            debugPrint(
                "File exists with corrected path, proceeding with metadata loading");
          } else {
            song.songImage = null;
            song.notifyListeners();
            return;
          }
        } else {
          song.songImage = null;
          song.notifyListeners();
          return;
        }
      }

      Metadata metadata =
          await MetadataGod.readMetadata(file: song.filePath.toString());
      
      // Extract image if available
      if (song.filePath != "" && metadata.picture?.data != null) {
        song.songImage = metadata.picture!.data;
      } else {
        // Ensure songImage is null if no cover art is found
        song.songImage = null;
      }
      
      // Extract duration from metadata
      if (metadata.duration != null) {
        song.duration = metadata.duration;
      }

      // Update song in database with new metadata
      await SongDatabase.updateSong(song);
      song.notifyListeners(); // Notify listeners that the song has been updated
    } catch (e) {
      debugPrint("File Path: ${song.filePath}");
      debugPrint("Error loading metadata: $e");
      // Ensure songImage is null on error
      song.songImage = null;
      song.notifyListeners(); // Still notify listeners even on error
    }
  }
}
