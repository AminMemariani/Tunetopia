import 'dart:io';
import 'dart:typed_data';
import 'package:music_player/models/song.dart';

/// Centralized mock data class for all test files
class MockData {
  static Directory? _tempDir;
  static File? _validSongFile;
  static File? _invalidSongFile;

  /// Initialize test files and directories
  static Future<void> initialize() async {
    _tempDir = await Directory.systemTemp.createTemp('tunetopia_test_');

    _validSongFile = File('${_tempDir!.path}/valid_song.mp3');
    _invalidSongFile = File('${_tempDir!.path}/invalid_song.mp3');

    await _validSongFile!.writeAsBytes(_createMockMp3Header());
    await _invalidSongFile!.writeAsString('This is not a music file');
  }

  /// Clean up test files and directories
  static Future<void> cleanup() async {
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
    }
  }

  /// Get the temporary directory
  static Directory get tempDir => _tempDir!;

  /// Get a valid song file
  static File get validSongFile => _validSongFile!;

  /// Get an invalid song file
  static File get invalidSongFile => _invalidSongFile!;

  /// Create a test song file with custom content
  static Future<File> createTestSongFile(String fileName,
      {Uint8List? content}) async {
    final file = File('${_tempDir!.path}/$fileName');
    await file.writeAsBytes(content ?? Uint8List.fromList([1, 2, 3, 4, 5]));
    return file;
  }

  /// Create a complete song with all metadata
  static Song createCompleteSong({
    String songName = 'Test Song',
    String songArtist = 'Test Artist',
    String songAlbum = 'Test Album',
    String? filePath,
    Uint8List? songImage,
    int? durationInSeconds,
  }) {
    return Song(
      songName: songName,
      songArtist: songArtist,
      songAlbum: songAlbum,
      filePath: filePath ?? _validSongFile?.path,
      songImage: songImage ?? Uint8List.fromList([1, 2, 3, 4, 5]),
      durationInSeconds: durationInSeconds ?? 225, // 3:45
    );
  }

  /// Create a minimal song with only required fields
  static Song createMinimalSong({
    String songName = 'Test Song',
    String? filePath,
  }) {
    return Song(
      songName: songName,
      filePath: filePath ?? _validSongFile?.path,
    );
  }

  /// Create a song with missing metadata
  static Song createSongWithMissingMetadata({
    String songName = 'Test Song',
    String? filePath,
  }) {
    return Song(
      songName: songName,
      filePath: filePath ?? _validSongFile?.path,
    );
  }

  /// Create a song with null file path
  static Song createSongWithNullPath({
    String songName = 'Test Song',
  }) {
    return Song(
      songName: songName,
      filePath: null,
    );
  }

  /// Create a song with empty file path
  static Song createSongWithEmptyPath({
    String songName = 'Test Song',
  }) {
    return Song(
      songName: songName,
      filePath: '',
    );
  }

  /// Create a song with long duration
  static Song createLongDurationSong({
    String songName = 'Long Song',
    String? filePath,
    int durationInSeconds = 3661, // 1:01:01
  }) {
    return Song(
      songName: songName,
      filePath: filePath ?? _validSongFile?.path,
      durationInSeconds: durationInSeconds,
    );
  }

  /// Create a song with long text fields
  static Song createLongTextSong({
    String? filePath,
  }) {
    return Song(
      songName: 'Very Long Song Name That Might Cause Wrapping Issues',
      songArtist: 'Very Long Artist Name That Might Cause Wrapping Issues',
      songAlbum: 'Very Long Album Name That Might Cause Wrapping Issues',
      filePath: filePath ??
          '/very/long/path/to/song/file/that/might/cause/wrapping/issues.mp3',
    );
  }

  /// Create a song with invalid cover art
  static Song createSongWithInvalidCoverArt({
    String songName = 'Song With Invalid Cover Art',
    String? filePath,
  }) {
    return Song(
      songName: songName,
      filePath: filePath ?? _validSongFile?.path,
      songImage: Uint8List.fromList([255, 255, 255]), // Invalid image data
    );
  }

  /// Create a song with no cover art
  static Song createSongWithoutCoverArt({
    String songName = 'Song Without Cover Art',
    String? filePath,
  }) {
    return Song(
      songName: songName,
      filePath: filePath ?? _validSongFile?.path,
      songImage: null,
    );
  }

  /// Create a non-existent file path
  static String get nonExistentFilePath => '/path/to/non/existent/file.mp3';

  /// Create mock MP3 header for valid music files
  static Uint8List _createMockMp3Header() {
    // Create a minimal MP3 file with ID3 tag
    final header = Uint8List(10);
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

    return header;
  }
}
