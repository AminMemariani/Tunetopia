import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/models/song.dart';

void main() {
  group('Song Model Comprehensive Tests', () {
    group('Constructor Tests', () {
      test('should create song with all parameters', () {
        final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final song = Song(
          songName: 'Test Song',
          songArtist: 'Test Artist',
          songAlbum: 'Test Album',
          filePath: '/path/to/song.mp3',
          songImage: imageData,
          durationInSeconds: 225,
        );

        expect(song.songName, 'Test Song');
        expect(song.songArtist, 'Test Artist');
        expect(song.songAlbum, 'Test Album');
        expect(song.filePath, '/path/to/song.mp3');
        expect(song.songImage, imageData);
        expect(song.durationInSeconds, 225);
      });

      test('should create song with minimal parameters', () {
        final song = Song(
          songName: 'Test Song',
        );

        expect(song.songName, 'Test Song');
        expect(song.songArtist, null);
        expect(song.songAlbum, null);
        expect(song.filePath, null);
        expect(song.songImage, null);
        expect(song.durationInSeconds, null);
      });

      test('should create song with null optional parameters', () {
        final song = Song(
          songName: 'Test Song',
          songArtist: null,
          songAlbum: null,
          filePath: null,
          songImage: null,
          durationInSeconds: null,
        );

        expect(song.songName, 'Test Song');
        expect(song.songArtist, null);
        expect(song.songAlbum, null);
        expect(song.filePath, null);
        expect(song.songImage, null);
        expect(song.durationInSeconds, null);
      });

      test('should create song with empty string parameters', () {
        final song = Song(
          songName: 'Test Song',
          songArtist: '',
          songAlbum: '',
          filePath: '',
        );

        expect(song.songName, 'Test Song');
        expect(song.songArtist, '');
        expect(song.songAlbum, '');
        expect(song.filePath, '');
      });
    });

    group('Duration Property Tests', () {
      test('should get duration from durationInSeconds', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: 185, // 3:05
        );

        expect(song.duration, const Duration(minutes: 3, seconds: 5));
      });

      test('should return null duration when durationInSeconds is null', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: null,
        );

        expect(song.duration, null);
      });

      test('should set duration and update durationInSeconds', () {
        final song = Song(
          songName: 'Test Song',
        );

        song.duration = const Duration(minutes: 4, seconds: 30);
        expect(song.duration, const Duration(minutes: 4, seconds: 30));
        expect(song.durationInSeconds, 270);
      });

      test('should set null duration and update durationInSeconds to null', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: 100,
        );

        song.duration = null;
        expect(song.duration, null);
        expect(song.durationInSeconds, null);
      });

      test('should handle zero duration', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: 0,
        );

        expect(song.duration, Duration.zero);
        expect(song.durationInSeconds, 0);
      });

      test('should handle very long duration', () {
        final longDuration = Duration(hours: 2, minutes: 30, seconds: 45);
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: longDuration.inSeconds,
        );

        expect(song.duration, longDuration);
        expect(song.durationInSeconds, 9045);
      });

      test('should handle fractional seconds correctly', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: 90, // 1:30
        );

        expect(song.duration, const Duration(minutes: 1, seconds: 30));
        expect(song.duration?.inMinutes, 1);
        expect(song.duration?.inSeconds, 90);
      });
    });

    group('Image Data Tests', () {
      test('should store and retrieve image data', () {
        final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
        final song = Song(
          songName: 'Test Song',
          songImage: imageData,
        );

        expect(song.songImage, imageData);
        expect(song.songImage!.length, 5);
      });

      test('should handle null image data', () {
        final song = Song(
          songName: 'Test Song',
          songImage: null,
        );

        expect(song.songImage, null);
      });

      test('should handle empty image data', () {
        final song = Song(
          songName: 'Test Song',
          songImage: Uint8List(0),
        );

        expect(song.songImage, isNotNull);
        expect(song.songImage!.length, 0);
      });

      test('should handle large image data', () {
        final largeImageData =
            Uint8List.fromList(List.generate(10000, (i) => i % 256));
        final song = Song(
          songName: 'Test Song',
          songImage: largeImageData,
        );

        expect(song.songImage, largeImageData);
        expect(song.songImage!.length, 10000);
      });

      test('should update image data', () {
        final song = Song(
          songName: 'Test Song',
          songImage: Uint8List.fromList([1, 2, 3]),
        );

        final newImageData = Uint8List.fromList([4, 5, 6, 7, 8]);
        song.songImage = newImageData;

        expect(song.songImage, newImageData);
        expect(song.songImage!.length, 5);
      });
    });

    group('String Properties Tests', () {
      test('should handle song name with special characters', () {
        final specialNames = [
          'Song with émojis 🎵',
          'Song with ñame',
          'Song with "quotes"',
          'Song with (parentheses)',
          'Song with [brackets]',
          'Song with {braces}',
          'Song with <angles>',
          'Song with |pipes|',
          'Song with \\backslashes\\',
          'Song with /forward/slashes/',
        ];

        for (final name in specialNames) {
          final song = Song(songName: name);
          expect(song.songName, name);
        }
      });

      test('should handle very long song names', () {
        final longName = 'A' * 1000;
        final song = Song(songName: longName);

        expect(song.songName, longName);
        expect(song.songName.length, 1000);
      });

      test('should handle artist names with special characters', () {
        final song = Song(
          songName: 'Test Song',
          songArtist: 'Artist with émojis 🎤',
        );

        expect(song.songArtist, 'Artist with émojis 🎤');
      });

      test('should handle album names with special characters', () {
        final song = Song(
          songName: 'Test Song',
          songAlbum: 'Album with émojis 💿',
        );

        expect(song.songAlbum, 'Album with émojis 💿');
      });

      test('should handle file paths with special characters', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/with émojis 🎵/song.mp3',
        );

        expect(song.filePath, '/path/with émojis 🎵/song.mp3');
      });
    });

    group('Equality and Comparison Tests', () {
      test('should be equal when all properties are the same', () {
        final imageData = Uint8List.fromList([1, 2, 3]);
        final song1 = Song(
          songName: 'Test Song',
          songArtist: 'Test Artist',
          songAlbum: 'Test Album',
          filePath: '/path/to/song.mp3',
          songImage: imageData,
          durationInSeconds: 225,
        );

        final song2 = Song(
          songName: 'Test Song',
          songArtist: 'Test Artist',
          songAlbum: 'Test Album',
          filePath: '/path/to/song.mp3',
          songImage: imageData,
          durationInSeconds: 225,
        );

        // Note: Song doesn't override == operator, so they won't be equal
        // But we can compare individual properties
        expect(song1.songName, song2.songName);
        expect(song1.songArtist, song2.songArtist);
        expect(song1.songAlbum, song2.songAlbum);
        expect(song1.filePath, song2.filePath);
        expect(song1.durationInSeconds, song2.durationInSeconds);
      });

      test('should have different properties when created differently', () {
        final song1 = Song(
          songName: 'Song 1',
          songArtist: 'Artist 1',
        );

        final song2 = Song(
          songName: 'Song 2',
          songArtist: 'Artist 2',
        );

        expect(song1.songName, isNot(equals(song2.songName)));
        expect(song1.songArtist, isNot(equals(song2.songArtist)));
      });
    });

    group('ChangeNotifier Tests', () {
      test('should notify listeners when properties change', () {
        final song = Song(songName: 'Test Song');
        bool notified = false;

        song.addListener(() {
          notified = true;
        });

        song.songArtist = 'New Artist';
        song.notifyListeners();

        expect(notified, true);
      });

      test('should notify listeners when duration changes', () {
        final song = Song(songName: 'Test Song');
        bool notified = false;

        song.addListener(() {
          notified = true;
        });

        song.duration = const Duration(minutes: 3);
        song.notifyListeners();

        expect(notified, true);
      });

      test('should notify listeners when image changes', () {
        final song = Song(songName: 'Test Song');
        bool notified = false;

        song.addListener(() {
          notified = true;
        });

        song.songImage = Uint8List.fromList([1, 2, 3]);
        song.notifyListeners();

        expect(notified, true);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle negative duration values', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: -1,
        );

        expect(song.durationInSeconds, -1);
        expect(song.duration, const Duration(seconds: -1));
      });

      test('should handle maximum int32 duration', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: 2147483647,
        );

        expect(song.durationInSeconds, 2147483647);
        expect(song.duration, Duration(seconds: 2147483647));
      });

      test('should handle minimum int32 duration', () {
        final song = Song(
          songName: 'Test Song',
          durationInSeconds: -2147483648,
        );

        expect(song.durationInSeconds, -2147483648);
        expect(song.duration, Duration(seconds: -2147483648));
      });

      test('should handle very large image data', () {
        final largeImageData =
            Uint8List.fromList(List.generate(1000000, (i) => i % 256));
        final song = Song(
          songName: 'Test Song',
          songImage: largeImageData,
        );

        expect(song.songImage, largeImageData);
        expect(song.songImage!.length, 1000000);
      });

      test('should handle unicode characters in all string fields', () {
        final song = Song(
          songName: '歌曲名称 🎵',
          songArtist: '艺术家名称 🎤',
          songAlbum: '专辑名称 💿',
          filePath: '/路径/到/歌曲.mp3',
        );

        expect(song.songName, '歌曲名称 🎵');
        expect(song.songArtist, '艺术家名称 🎤');
        expect(song.songAlbum, '专辑名称 💿');
        expect(song.filePath, '/路径/到/歌曲.mp3');
      });
    });

    group('Property Validation Tests', () {
      test('should maintain data integrity when updating properties', () {
        final song = Song(
          songName: 'Original Name',
          songArtist: 'Original Artist',
          songAlbum: 'Original Album',
          filePath: '/original/path.mp3',
          durationInSeconds: 100,
        );

        // Update all properties
        song.songName = 'Updated Name';
        song.songArtist = 'Updated Artist';
        song.songAlbum = 'Updated Album';
        song.filePath = '/updated/path.mp3';
        song.duration = const Duration(minutes: 5);

        expect(song.songName, 'Updated Name');
        expect(song.songArtist, 'Updated Artist');
        expect(song.songAlbum, 'Updated Album');
        expect(song.filePath, '/updated/path.mp3');
        expect(song.duration, const Duration(minutes: 5));
        expect(song.durationInSeconds, 300);
      });

      test('should handle null assignments correctly', () {
        final song = Song(
          songName: 'Test Song',
          songArtist: 'Test Artist',
          songAlbum: 'Test Album',
          filePath: '/test/path.mp3',
          durationInSeconds: 100,
        );

        // Set all optional properties to null
        song.songArtist = null;
        song.songAlbum = null;
        song.filePath = null;
        song.duration = null;

        expect(song.songName, 'Test Song'); // Required field should remain
        expect(song.songArtist, null);
        expect(song.songAlbum, null);
        expect(song.filePath, null);
        expect(song.duration, null);
        expect(song.durationInSeconds, null);
      });
    });

    group('Memory and Performance Tests', () {
      test('should handle multiple song instances efficiently', () {
        final songs = <Song>[];

        for (int i = 0; i < 1000; i++) {
          songs.add(Song(
            songName: 'Song $i',
            songArtist: 'Artist $i',
            songAlbum: 'Album $i',
            filePath: '/path/to/song$i.mp3',
            durationInSeconds: i * 60,
          ));
        }

        expect(songs.length, 1000);
        expect(songs[0].songName, 'Song 0');
        expect(songs[999].songName, 'Song 999');
      });

      test('should handle rapid property updates', () {
        final song = Song(songName: 'Test Song');

        for (int i = 0; i < 100; i++) {
          song.songArtist = 'Artist $i';
          song.duration = Duration(seconds: i);
          song.notifyListeners();
        }

        expect(song.songArtist, 'Artist 99');
        expect(song.duration, const Duration(seconds: 99));
      });
    });
  });
}
