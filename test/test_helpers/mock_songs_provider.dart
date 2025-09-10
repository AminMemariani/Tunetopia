import 'package:flutter/foundation.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/providers/songs.dart';

class MockSongsProvider extends Songs {
  @override
  Future<void> loadImage(Song song) async {
    // Mock implementation that doesn't call the real metadata loading
    // This prevents the flutter_rust_bridge error in tests
    // Complete immediately to avoid loading states in tests
    // Don't actually load metadata, just simulate completion
  }

  @override
  Future<void> removeSongFromLibrary(Song song) async {
    // Mock implementation for removing songs
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
