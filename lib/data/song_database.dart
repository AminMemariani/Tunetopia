import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/models/song.dart';

class SongDatabase {
  static const String _boxName = 'songs_box';
  static Box<Song>? _box;

  // Initialize Hive and open the songs box
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register the Song adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongAdapter());
    }

    // Open the songs box
    _box = await Hive.openBox<Song>(_boxName);
  }

  // Get all songs from the database
  static List<Song> getAllSongs() {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _box!.values.toList();
  }

  // Add a song to the database
  static Future<void> addSong(Song song) async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    // Check if song already exists by file path
    final existingSong =
        _box!.values.where((s) => s.filePath == song.filePath).firstOrNull;
    if (existingSong == null) {
      await _box!.add(song);
    }
  }

  // Add multiple songs to the database
  static Future<void> addSongs(List<Song> songs) async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    for (final song in songs) {
      await addSong(song);
    }
  }

  // Update a song in the database
  static Future<void> updateSong(Song song) async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    final key =
        _box!.values.toList().indexWhere((s) => s.filePath == song.filePath);
    if (key != -1) {
      await _box!.putAt(key, song);
    }
  }

  // Remove a song from the database
  static Future<void> removeSong(Song song) async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    final key =
        _box!.values.toList().indexWhere((s) => s.filePath == song.filePath);
    if (key != -1) {
      await _box!.deleteAt(key);
    }
  }

  // Clear all songs from the database
  static Future<void> clearAllSongs() async {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    await _box!.clear();
  }

  // Check if a song exists by file path
  static bool songExists(String filePath) {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    return _box!.values.any((song) => song.filePath == filePath);
  }

  // Get song by file path
  static Song? getSongByPath(String filePath) {
    if (_box == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }

    try {
      return _box!.values.firstWhere((song) => song.filePath == filePath);
    } catch (e) {
      return null;
    }
  }

  // Close the database
  static Future<void> close() async {
    if (_box != null) {
      await _box!.close();
      _box = null;
    }
  }
}
