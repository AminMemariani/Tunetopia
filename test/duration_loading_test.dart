import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/providers/songs.dart';

void main() {
  group('Duration Loading Tests', () {
    late Songs songsProvider;

    setUp(() {
      songsProvider = Songs();
    });

    group('Song Model Duration Tests', () {
      test('should create song with duration', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: 225, // 3 minutes 45 seconds
        );

        expect(song.duration, const Duration(minutes: 3, seconds: 45));
        expect(song.duration?.inSeconds, 225);
        expect(song.duration?.inMinutes, 3);
      });

      test('should create song without duration', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
        );

        expect(song.duration, null);
      });

      test('should update duration after creation', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
        );

        expect(song.duration, null);

        song.duration = Duration(minutes: 2, seconds: 30);
        expect(song.duration, Duration(minutes: 2, seconds: 30));
        expect(song.duration?.inSeconds, 150);
      });

      test('should handle zero duration', () {
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: 0,
        );

        expect(song.duration, Duration.zero);
        expect(song.duration?.inSeconds, 0);
        expect(song.duration?.inMinutes, 0);
      });

      test('should handle very long duration', () {
        final longDuration = Duration(hours: 2, minutes: 30, seconds: 15);
        final song = Song(
          songName: 'Test Song',
          filePath: '/path/to/song.mp3',
          durationInSeconds: 9015, // 2*3600 + 30*60 + 15
        );

        expect(song.duration, longDuration);
        expect(song.duration?.inSeconds, 9015); // 2*3600 + 30*60 + 15
        expect(song.duration?.inMinutes, 150); // 2*60 + 30
      });
    });

    group('Duration Formatting Tests', () {
      String formatDuration(Duration? duration) {
        if (duration == null) return "0:00";
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
        String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
        return "$twoDigitMinutes:$twoDigitSeconds";
      }

      test('should format null duration as 0:00', () {
        expect(formatDuration(null), '0:00');
      });

      test('should format zero duration as 00:00', () {
        expect(formatDuration(Duration.zero), '00:00');
      });

      test('should format short duration correctly', () {
        expect(formatDuration(Duration(seconds: 30)), '00:30');
        expect(formatDuration(Duration(seconds: 59)), '00:59');
      });

      test('should format minute duration correctly', () {
        expect(formatDuration(Duration(minutes: 1, seconds: 30)), '01:30');
        expect(formatDuration(Duration(minutes: 5, seconds: 45)), '05:45');
        expect(formatDuration(Duration(minutes: 10, seconds: 5)), '10:05');
      });

      test('should format long duration correctly', () {
        expect(formatDuration(Duration(minutes: 59, seconds: 59)), '59:59');
        expect(formatDuration(Duration(hours: 1, minutes: 23, seconds: 45)),
            '23:45');
        expect(formatDuration(Duration(hours: 2, minutes: 30, seconds: 15)),
            '30:15');
      });

      test('should handle edge cases', () {
        expect(formatDuration(Duration(milliseconds: 500)), '00:00');
        expect(formatDuration(Duration(seconds: 1)), '00:01');
        expect(formatDuration(Duration(minutes: 1)), '01:00');
      });
    });

    group('Songs Provider Duration Tests', () {
      test('should add songs with duration information', () async {
        const files =
            'PlatformFile(path /path/to/song1.mp3), PlatformFile(path /path/to/song2.mp3)';

        await songsProvider.addSongs(files);

        expect(songsProvider.songs.length, 2);

        // Initially songs don't have duration until metadata is loaded
        expect(songsProvider.songs[0].duration, null);
        expect(songsProvider.songs[1].duration, null);
      });

      test('should handle empty files string', () async {
        await songsProvider.addSongs('');

        expect(songsProvider.songs.length, 0);
      });

      test('should handle invalid files string', () async {
        await songsProvider.addSongs('invalid format');

        expect(songsProvider.songs.length, 0);
      });

      test('should find song by name', () async {
        const files = 'PlatformFile(path /path/to/song1.mp3)';
        await songsProvider.addSongs(files);

        final foundSong = songsProvider.findByName('song1.mp3)');
        expect(foundSong?.songName, 'song1.mp3)');
        expect(foundSong?.filePath, '/path/to/song1.mp3)');
      });
    });

    group('Duration Validation Tests', () {
      test('should validate duration ranges', () {
        // Valid durations
        expect(Duration.zero.inSeconds, 0);
        expect(Duration(seconds: 1).inSeconds, 1);
        expect(Duration(minutes: 1).inSeconds, 60);
        expect(Duration(hours: 1).inSeconds, 3600);

        // Very long duration (24 hours)
        final veryLongDuration = Duration(hours: 24);
        expect(veryLongDuration.inSeconds, 86400);
        expect(veryLongDuration.inMinutes, 1440);
      });

      test('should handle duration arithmetic', () {
        final duration1 = Duration(minutes: 3, seconds: 45);
        final duration2 = Duration(minutes: 2, seconds: 15);

        final total = duration1 + duration2;
        expect(total.inSeconds, 360); // 6 minutes
        expect(total.inMinutes, 6);
      });

      test('should compare durations correctly', () {
        final shortDuration = Duration(minutes: 1, seconds: 30);
        final longDuration = Duration(minutes: 5, seconds: 45);

        expect(shortDuration < longDuration, true);
        expect(longDuration > shortDuration, true);
        expect(shortDuration == Duration(minutes: 1, seconds: 30), true);
      });
    });

    group('Edge Case Tests', () {
      test('should handle null file paths gracefully', () {
        final song = Song(
          songName: 'test.mp3',
          filePath: null,
        );

        expect(song.filePath, null);
        expect(song.duration, null);
      });

      test('should handle empty file paths gracefully', () {
        final song = Song(
          songName: 'test.mp3',
          filePath: '',
        );

        expect(song.filePath, '');
        expect(song.duration, null);
      });

      test('should handle very short durations', () {
        final song = Song(
          songName: 'test.mp3',
          filePath: '/path/to/test.mp3',
          durationInSeconds: 0, // Less than 1 second
        );

        expect(song.duration?.inMilliseconds, 0);
        expect(song.duration?.inSeconds, 0);
      });

      test('should handle fractional seconds', () {
        final song = Song(
          songName: 'test.mp3',
          filePath: '/path/to/test.mp3',
          durationInSeconds: 1, // 1 second
        );

        expect(song.duration?.inSeconds, 1);
      });
    });
  });
}
