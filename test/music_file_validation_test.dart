import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/song_database.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/providers/songs.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing (without Flutter path provider)
    Hive.init('test_hive_music');
    
    // Initialize the song database
    await SongDatabase.initialize();
  });

  tearDownAll(() async {
    // Close Hive boxes
    await Hive.close();
  });

  group('Music File Validation Tests', () {
    late Directory tempDir;
    late File validMp3File;
    late File invalidFile;
    late File emptyFile;

    setUpAll(() async {
      // Create temporary directory for test files
      tempDir = await Directory.systemTemp.createTemp('music_test_');

      // Create a mock MP3 file with proper header
      validMp3File = File('${tempDir.path}/test_song.mp3');
      await validMp3File.writeAsBytes(_createMockMp3Header());

      // Create an invalid file (text file with .mp3 extension)
      invalidFile = File('${tempDir.path}/invalid.mp3');
      await invalidFile.writeAsString('This is not a music file' * 50); // Make it larger than 1KB

      // Create an empty file
      emptyFile = File('${tempDir.path}/empty.mp3');
      await emptyFile.create();
    });

    tearDownAll(() async {
      // Clean up temporary files
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('File Extension Validation', () {
      test('should accept valid music file extensions', () {
        final validExtensions = [
          '.mp3',
          '.wav',
          '.flac',
          '.m4a',
          '.aac',
          '.ogg'
        ];

        for (final ext in validExtensions) {
          final song = Song(
            songName: 'test$ext',
            filePath: '/path/to/test$ext',
          );
          expect(_isValidMusicExtension(song.filePath!), true,
              reason: 'Extension $ext should be valid');
        }
      });

      test('should reject invalid file extensions', () {
        final invalidExtensions = ['.txt', '.pdf', '.jpg', '.doc', '.exe'];

        for (final ext in invalidExtensions) {
          final song = Song(
            songName: 'test$ext',
            filePath: '/path/to/test$ext',
          );
          expect(_isValidMusicExtension(song.filePath!), false,
              reason: 'Extension $ext should be invalid');
        }
      });

      test('should handle files without extensions', () {
        final song = Song(
          songName: 'testfile',
          filePath: '/path/to/testfile',
        );
        expect(_isValidMusicExtension(song.filePath!), false);
      });

      test('should handle case insensitive extensions', () {
        final extensions = ['.MP3', '.WAV', '.FlAc', '.M4A'];

        for (final ext in extensions) {
          final song = Song(
            songName: 'test$ext',
            filePath: '/path/to/test$ext',
          );
          expect(_isValidMusicExtension(song.filePath!), true,
              reason: 'Extension $ext should be valid (case insensitive)');
        }
      });
    });

    group('File Existence and Accessibility', () {
      test('should validate existing music file', () async {
        final song = Song(
          songName: 'test_song.mp3',
          filePath: validMp3File.path,
        );

        expect(await _checkFileExists(song.filePath!), true);
        expect(await _isFileAccessible(song.filePath!), true);
      });

      test('should handle non-existent file', () async {
        final song = Song(
          songName: 'non_existent.mp3',
          filePath: '/path/to/non_existent.mp3',
        );

        expect(await _checkFileExists(song.filePath!), false);
        expect(await _isFileAccessible(song.filePath!), false);
      });

      test('should handle null file path', () async {
        final song = Song(
          songName: 'test.mp3',
          filePath: null,
        );

        expect(await _checkFileExists(song.filePath ?? ''), false);
        expect(await _isFileAccessible(song.filePath ?? ''), false);
      });

      test('should handle empty file path', () async {
        final song = Song(
          songName: 'test.mp3',
          filePath: '',
        );

        expect(await _checkFileExists(song.filePath!), false);
        expect(await _isFileAccessible(song.filePath!), false);
      });

      test('should handle empty file', () async {
        final song = Song(
          songName: 'empty.mp3',
          filePath: emptyFile.path,
        );

        expect(await _checkFileExists(song.filePath!), true);
        expect(await _isFileAccessible(song.filePath!),
            false); // Empty file is not valid
      });
    });

    group('File Size Validation', () {
      test('should accept files with reasonable size', () async {
        final song = Song(
          songName: 'test_song.mp3',
          filePath: validMp3File.path,
        );

        final fileSize = await _getFileSize(song.filePath!);
        expect(fileSize, greaterThan(0));
        expect(_isValidFileSize(fileSize), true);
      });

      test('should reject files that are too small', () {
        expect(_isValidFileSize(0), false);
        expect(_isValidFileSize(100), false); // Less than 1KB
      });

      test('should reject files that are too large', () {
        expect(_isValidFileSize(500 * 1024 * 1024 * 1024), false); // 500GB
        expect(_isValidFileSize(1024 * 1024 * 1024 * 1024), false); // 1TB
      });

      test('should accept files within reasonable size range', () {
        expect(_isValidFileSize(1024), true); // 1KB
        expect(_isValidFileSize(1024 * 1024), true); // 1MB
        expect(_isValidFileSize(100 * 1024 * 1024), true); // 100MB
        expect(_isValidFileSize(500 * 1024 * 1024), true); // 500MB
      });
    });

    group('File Header Validation', () {
      test('should validate MP3 file headers', () async {
        final song = Song(
          songName: 'test_song.mp3',
          filePath: validMp3File.path,
        );

        expect(await _hasValidMusicHeader(song.filePath!), true);
      });

      test('should reject files with invalid headers', () async {
        final song = Song(
          songName: 'invalid.mp3',
          filePath: invalidFile.path,
        );

        expect(await _hasValidMusicHeader(song.filePath!), false);
      });

      test('should handle files that cannot be read', () async {
        final song = Song(
          songName: 'non_existent.mp3',
          filePath: '/path/to/non_existent.mp3',
        );

        expect(await _hasValidMusicHeader(song.filePath!), false);
      });
    });

    group('Complete Music File Validation', () {
      test('should validate a complete music file', () async {
        final song = Song(
          songName: 'test_song.mp3',
          filePath: validMp3File.path,
        );

        expect(await _isValidMusicFile(song), true);
      });

      test('should reject invalid music files', () async {
        final song = Song(
          songName: 'invalid.mp3',
          filePath: invalidFile.path,
        );

        expect(await _isValidMusicFile(song), false);
      });

      test('should reject non-existent files', () async {
        final song = Song(
          songName: 'non_existent.mp3',
          filePath: '/path/to/non_existent.mp3',
        );

        expect(await _isValidMusicFile(song), false);
      });

      test('should reject files with wrong extensions', () async {
        final song = Song(
          songName: 'test.txt',
          filePath: '/path/to/test.txt',
        );

        expect(await _isValidMusicFile(song), false);
      });
    });

    group('Songs Provider Integration', () {
      late Songs songsProvider;

      setUp(() async {
        songsProvider = Songs();
        // Clear the database to ensure clean state for each test
        await SongDatabase.clearAllSongs();
      });

      test('should add valid music files', () async {
        final files = 'PlatformFile(path ${validMp3File.path})';

        await songsProvider.addSongs(files);

        expect(songsProvider.songs.length, 1);
        expect(songsProvider.songs[0].songName, 'test_song.mp3');
        expect(songsProvider.songs[0].filePath, validMp3File.path);
      });

      test('should handle mixed valid and invalid files', () async {
        final files =
            'PlatformFile(path ${validMp3File.path}), PlatformFile(path ${invalidFile.path})';

        await songsProvider.addSongs(files);

        // Should add both files, validation happens later
        expect(songsProvider.songs.length, 2);
      });

      test('should handle empty files list', () async {
        await songsProvider.addSongs('');

        expect(songsProvider.songs.length, 0);
      });
    });
  });
}

// Helper functions for validation
bool _isValidMusicExtension(String filePath) {
  final extension = filePath.toLowerCase().split('.').last;
  const validExtensions = ['mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg'];
  return validExtensions.contains(extension);
}

Future<bool> _checkFileExists(String filePath) async {
  try {
    final file = File(filePath);
    return await file.exists();
  } catch (e) {
    return false;
  }
}

Future<bool> _isFileAccessible(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final stat = await file.stat();
    return stat.size > 0;
  } catch (e) {
    return false;
  }
}

Future<int> _getFileSize(String filePath) async {
  try {
    final file = File(filePath);
    final stat = await file.stat();
    return stat.size;
  } catch (e) {
    return 0;
  }
}

bool _isValidFileSize(int sizeInBytes) {
  const minSize = 1024; // 1KB minimum
  const maxSize = 500 * 1024 * 1024; // 500MB maximum
  return sizeInBytes >= minSize && sizeInBytes <= maxSize;
}

Future<bool> _hasValidMusicHeader(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final bytes = await file.readAsBytes();
    if (bytes.length < 4) return false;

    // Check for MP3 header (ID3 tag or MPEG frame)
    if (bytes.length >= 3) {
      // ID3 tag
      if (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
        return true;
      }

      // MPEG frame sync
      if (bytes.length >= 2) {
        final firstTwoBytes = (bytes[0] << 8) | bytes[1];
        if ((firstTwoBytes & 0xFFE0) == 0xFFE0) {
          return true;
        }
      }
    }

    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> _isValidMusicFile(Song song) async {
  if (song.filePath == null || song.filePath!.isEmpty) return false;

  // Check file extension
  if (!_isValidMusicExtension(song.filePath!)) return false;

  // Check file existence
  if (!await _checkFileExists(song.filePath!)) return false;

  // Check file accessibility
  if (!await _isFileAccessible(song.filePath!)) return false;

  // Check file size
  final fileSize = await _getFileSize(song.filePath!);
  if (!_isValidFileSize(fileSize)) return false;

  // Check file header
  if (!await _hasValidMusicHeader(song.filePath!)) return false;

  return true;
}

// Helper function to create a mock MP3 header
Uint8List _createMockMp3Header() {
  // Create a minimal MP3 file with ID3 tag (at least 1KB to pass size validation)
  final header = Uint8List(1024); // 1KB minimum
  
  // ID3 tag header
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

  // Fill the rest with dummy data to reach 1KB
  for (int i = 10; i < 1024; i++) {
    header[i] = 0x00;
  }

  return header;
}
