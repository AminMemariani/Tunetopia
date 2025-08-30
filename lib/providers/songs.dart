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
    } catch (e) {
      debugPrint("Error loading songs from database: $e");
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
