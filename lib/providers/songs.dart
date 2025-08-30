import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/data/song_database.dart';

class Songs with ChangeNotifier {
  final List<Song> _songs = [];
  bool _isInitialized = false;

  // Initialize the provider and load songs from database
  Future<void> initialize() async {
    if (!_isInitialized) {
      await SongDatabase.initialize();
      await loadSongsFromDatabase();
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
    RegExp regex = RegExp(r"PlatformFile\(path ([^,]*)");

    Iterable<Match?> matches = regex.allMatches(files);

    if (matches.isNotEmpty) {
      List<Song> newSongs = [];
      
      for (Match? match in matches) {
        final filePath = match!.group(1)!.trim();
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
      Metadata metadata =
          await MetadataGod.readMetadata(file: song.filePath.toString());
      
      // Extract image if available
      if (song.filePath != "" && metadata.picture?.data != null) {
        song.songImage = metadata.picture!.data;
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
    }
  }
}
