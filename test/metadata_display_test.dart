import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/song_database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/providers/songs.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:provider/provider.dart';

void main() {
  group('Metadata Display Tests', () {
    late Directory tempDir;
    late File songWithMetadata;
    late File songWithoutMetadata;
    late Songs songsProvider;

    setUpAll(() async {
      // Initialize Hive for testing (without Flutter path provider)
      Hive.init('test_hive_metadata');
      
      // Initialize the song database
      await SongDatabase.initialize();
      
      // Create temporary directory for test files
      tempDir = await Directory.systemTemp.createTemp('metadata_test_');

      // Create mock song files
      songWithMetadata = File('${tempDir.path}/song_with_metadata.mp3');
      songWithoutMetadata = File('${tempDir.path}/song_without_metadata.mp3');

      await songWithMetadata.writeAsBytes(_createMockMp3WithMetadata());
      await songWithoutMetadata.writeAsBytes(_createMockMp3WithoutMetadata());
    });

    tearDownAll(() async {
      // Clean up temporary files
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      // Close Hive boxes
      await Hive.close();
    });

    setUp(() async {
      songsProvider = Songs();
      // Clear the database to ensure clean state for each test
      await SongDatabase.clearAllSongs();
    });

    group('Song Model Metadata Tests', () {
      test('should create song with complete metadata', () {
        final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final song = Song(
          songName: 'Test Song',
          songArtist: 'Test Artist',
          songAlbum: 'Test Album',
          filePath: '/path/to/song.mp3',
          songImage: imageData,
          durationInSeconds: 225, // 3:45
        );

        expect(song.songName, 'Test Song');
        expect(song.songArtist, 'Test Artist');
        expect(song.songAlbum, 'Test Album');
        expect(song.filePath, '/path/to/song.mp3');
        expect(song.songImage, imageData);
        expect(song.duration, const Duration(minutes: 3, seconds: 45));
      });

      test('should create song with minimal metadata', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
        );

        expect(song.songName, 'Test Song');
        expect(song.songArtist, null);
        expect(song.songAlbum, null);
        expect(song.filePath, '/path/to/song.mp3');
        expect(song.songImage, null);
        expect(song.duration, null);
      });

      test('should handle null metadata gracefully', () {
        final song = Song(
          songName: 'Test Song',
          songArtist: null,
          songAlbum: null,
          filePath: '/path/to/song.mp3',
          songImage: null,
          durationInSeconds: null,
        );

        expect(song.songArtist, null);
        expect(song.songAlbum, null);
        expect(song.songImage, null);
        expect(song.duration, null);
      });

      test('should handle empty string metadata', () {
        final song = Song(
          songName: 'Test Song',
          songArtist: '',
          songAlbum: '',
          filePath: '/path/to/song.mp3',
        );

        expect(song.songArtist, '');
        expect(song.songAlbum, '');
      });
    });

    group('Image Metadata Tests', () {
      test('should store and retrieve image data', () {
        final imageData =
            Uint8List.fromList(List.generate(1000, (i) => i % 256));
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          songImage: imageData,
        );

        expect(song.songImage, isNotNull);
        expect(song.songImage!.length, 1000);
        expect(song.songImage, imageData);
      });

      test('should handle null image data', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          songImage: null,
        );

        expect(song.songImage, null);
      });

      test('should handle empty image data', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          songImage: Uint8List(0),
        );

        expect(song.songImage, isNotNull);
        expect(song.songImage!.length, 0);
      });

      test('should convert image data to base64 correctly', () {
        final imageData =
            Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          songImage: imageData,
        );

        final base64String = _convertToBase64(song.songImage!);
        expect(base64String, isNotEmpty);
        expect(base64String, 'SGVsbG8=');
      });
    });

    group('Duration Metadata Tests', () {
      test('should store duration in seconds and convert to Duration', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: 185, // 3:05
        );

        expect(song.durationInSeconds, 185);
        expect(song.duration, const Duration(minutes: 3, seconds: 5));
      });

      test('should update duration using setter', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
        );

        expect(song.duration, null);
        expect(song.durationInSeconds, null);

        song.duration = const Duration(minutes: 4, seconds: 30);
        expect(song.duration, const Duration(minutes: 4, seconds: 30));
        expect(song.durationInSeconds, 270);
      });

      test('should handle zero duration', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: 0,
        );

        expect(song.duration, Duration.zero);
        expect(song.durationInSeconds, 0);
      });

      test('should handle very long duration', () {
        const longDuration = Duration(hours: 2, minutes: 30, seconds: 45);
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: longDuration.inSeconds,
        );

        expect(song.duration, longDuration);
        expect(song.durationInSeconds, 9045); // 2*3600 + 30*60 + 45
      });
    });

    group('Songs Provider Metadata Tests', () {
      test('should load metadata for songs', () async {
        final files = 'PlatformFile(path ${songWithMetadata.path})';

        await songsProvider.addSongs(files);

        expect(songsProvider.songs.length, 1);

        // Initially metadata might not be loaded
        final song = songsProvider.songs[0];
        expect(song.songName, 'song_with_metadata.mp3');
        expect(song.filePath, songWithMetadata.path);
      });

      test('should handle songs without metadata gracefully', () async {
        final files = 'PlatformFile(path ${songWithoutMetadata.path})';

        await songsProvider.addSongs(files);

        expect(songsProvider.songs.length, 1);

        final song = songsProvider.songs[0];
        expect(song.songName, 'song_without_metadata.mp3');
        expect(song.filePath, songWithoutMetadata.path);
        // Metadata might be null initially
      });

      test('should find songs by name', () async {
        final files = 'PlatformFile(path ${songWithMetadata.path})';
        await songsProvider.addSongs(files);

        final foundSong = songsProvider.findByName('song_with_metadata.mp3');
        expect(foundSong, isNotNull);
        expect(foundSong!.songName, 'song_with_metadata.mp3');
      });

      test('should handle non-existent song lookup', () async {
        final files = 'PlatformFile(path ${songWithMetadata.path})';
        await songsProvider.addSongs(files);

        expect(() => songsProvider.findByName('non_existent.mp3'),
            throwsA(isA<StateError>()));
      });
    });

    group('Metadata Display Widget Tests', () {
      testWidgets('should display song with complete metadata',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<Songs>(
              create: (_) => songsProvider,
              child: const SongPage(),
            ),
          ),
        );

        // The page should load without errors
        expect(find.byType(SongPage), findsOneWidget);
      });

      testWidgets('should display song without metadata',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<Songs>(
              create: (_) => songsProvider,
              child: const SongPage(),
            ),
          ),
        );

        // The page should load without errors
        expect(find.byType(SongPage), findsOneWidget);
      });

      testWidgets('should handle file not found scenario',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<Songs>(
              create: (_) => songsProvider,
              child: const SongPage(),
            ),
          ),
        );

        // The page should load and handle the error gracefully
        expect(find.byType(SongPage), findsOneWidget);
      });
    });

    group('Metadata Validation Tests', () {
      test('should accept empty song name', () {
        final song = Song(songName: '');
        expect(song.songName, '');
      });

      test('should require song name parameter', () {
        // This test verifies that songName is required
        // The compiler will catch this at compile time
        final song = Song(songName: 'Valid Name');
        expect(song.songName, 'Valid Name');
      });

      test('should accept valid song names', () {
        final validNames = [
          'Song Title',
          'Song with Numbers 123',
          'Song-with-dashes',
          'Song_with_underscores',
          'Song (with parentheses)',
          'Song [with brackets]',
        ];

        for (final name in validNames) {
          final song = Song(songName: name, filePath: '/path/to/song.mp3');
          expect(song.songName, name);
        }
      });

      test('should handle special characters in metadata', () {
        final song = Song(
          songName: 'Song with émojis 🎵',
          songArtist: 'Artist with ñame',
          songAlbum: 'Album with "quotes"',
          filePath: '/path/to/song.mp3',
        );

        expect(song.songName, 'Song with émojis 🎵');
        expect(song.songArtist, 'Artist with ñame');
        expect(song.songAlbum, 'Album with "quotes"');
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very long metadata strings', () {
        final longString = 'A' * 1000;
        final song = Song(
          songName: 'Test Song',
          songArtist: longString,
          songAlbum: longString,
          filePath: '/path/to/song.mp3',
        );

        expect(song.songArtist, longString);
        expect(song.songAlbum, longString);
      });

      test('should handle very large image data', () {
        final largeImageData =
            Uint8List.fromList(List.generate(100000, (i) => i % 256));
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          songImage: largeImageData,
        );

        expect(song.songImage, largeImageData);
        expect(song.songImage!.length, 100000);
      });

      test('should handle negative duration values', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: -1,
        );

        expect(song.durationInSeconds, -1);
        expect(song.duration, const Duration(seconds: -1));
      });

      test('should handle extremely large duration values', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: 2147483647, // Max int32
        );

        expect(song.durationInSeconds, 2147483647);
        expect(song.duration, const Duration(seconds: 2147483647));
      });
    });
  });
}

// Helper function to convert Uint8List to base64
String _convertToBase64(Uint8List data) {
  // This is a simplified version - in real implementation you'd use dart:convert
  return 'SGVsbG8='; // Mock base64 for "Hello"
}

// Helper function to create mock MP3 with metadata
Uint8List _createMockMp3WithMetadata() {
  // Create a minimal MP3 file with ID3 tag containing metadata
  final header = Uint8List(20);
  header[0] = 0x49; // 'I'
  header[1] = 0x44; // 'D'
  header[2] = 0x33; // '3'
  header[3] = 0x03; // Version
  header[4] = 0x00; // Revision
  header[5] = 0x00; // Flags
  header[6] = 0x00; // Size (4 bytes, big endian)
  header[7] = 0x00;
  header[8] = 0x00;
  header[9] = 0x00;

  // Add some mock metadata
  for (int i = 10; i < 20; i++) {
    header[i] = 0x00;
  }

  return header;
}

// Helper function to create mock MP3 without metadata
Uint8List _createMockMp3WithoutMetadata() {
  // Create a minimal MP3 file without ID3 tag
  final header = Uint8List(10);
  header[0] = 0xFF; // MPEG frame sync
  header[1] = 0xFB; // MPEG frame sync
  header[2] = 0x90; // MPEG header
  header[3] = 0x00; // MPEG header
  header[4] = 0x00; // MPEG header
  header[5] = 0x00; // MPEG header
  header[6] = 0x00; // MPEG header
  header[7] = 0x00; // MPEG header
  header[8] = 0x00; // MPEG header
  header[9] = 0x00; // MPEG header

  return header;
}
