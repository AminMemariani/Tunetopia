// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/providers/songs.dart';
import 'package:music_player/pages/widgets/controls.dart';

void main() {
  group('Song Model Tests', () {
    test('should create song with duration', () {
      final song = Song(
        songName: 'Test Song',
        filePath: '/path/to/song.mp3',
        durationInSeconds: 225, // 3 minutes 45 seconds
      );

      expect(song.songName, 'Test Song');
      expect(song.filePath, '/path/to/song.mp3');
      expect(song.duration, Duration(minutes: 3, seconds: 45));
    });

    test('should create song without duration', () {
      final song = Song(
        songName: 'Test Song',
        filePath: '/path/to/song.mp3',
      );

      expect(song.songName, 'Test Song');
      expect(song.filePath, '/path/to/song.mp3');
      expect(song.duration, null);
    });

    test('should update duration', () {
      final song = Song(
        songName: 'Test Song',
        filePath: '/path/to/song.mp3',
      );

      expect(song.duration, null);

      song.duration = Duration(minutes: 2, seconds: 30);
      expect(song.duration, Duration(minutes: 2, seconds: 30));
    });
  });

  group('Songs Provider Tests', () {
    late Songs songsProvider;

    setUp(() {
      songsProvider = Songs();
    });

    test('should add songs from file paths', () async {
      const files =
          'PlatformFile(path /path/to/song1.mp3), PlatformFile(path /path/to/song2.mp3)';

      await songsProvider.addSongs(files);

      expect(songsProvider.songs.length, 2);
      expect(songsProvider.songs[0].songName, 'song1.mp3)');
      expect(songsProvider.songs[0].filePath, '/path/to/song1.mp3)');
      expect(songsProvider.songs[1].songName, 'song2.mp3)');
      expect(songsProvider.songs[1].filePath, '/path/to/song2.mp3)');
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

    test('should return null when song not found', () async {
      const files = 'PlatformFile(path /path/to/song1.mp3)';
      await songsProvider.addSongs(files);

      expect(
          () => songsProvider.findByName('nonexistent.mp3'), throwsStateError);
    });
  });

  group('Controls Widget Tests', () {
    testWidgets('should display duration correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(
              duration: Duration(minutes: 3, seconds: 45),
            ),
          ),
        ),
      );

      expect(find.text('0:00'), findsOneWidget); // Start time
      expect(find.text('03:45'), findsOneWidget); // End time (duration)
    });

    testWidgets('should display 0:00 when duration is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: null),
          ),
        ),
      );

      expect(find.text('0:00'), findsNWidgets(2)); // Both start and end time
    });

    testWidgets('should display 0:00 when duration is zero',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration.zero),
          ),
        ),
      );

      expect(find.text('0:00'), findsOneWidget); // Only start time shows 0:00
      expect(find.text('00:00'), findsOneWidget); // End time shows 00:00
    });

    testWidgets('should format duration correctly for different values',
        (WidgetTester tester) async {
      // Test 1 minute 30 seconds
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration(minutes: 1, seconds: 30)),
          ),
        ),
      );
      expect(find.text('01:30'), findsOneWidget);

      // Test 10 minutes 5 seconds
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration(minutes: 10, seconds: 5)),
          ),
        ),
      );
      expect(find.text('10:05'), findsOneWidget);

      // Test 1 hour 23 minutes 45 seconds (should show only MM:SS)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(
                duration: Duration(hours: 1, minutes: 23, seconds: 45)),
          ),
        ),
      );
      expect(find.text('23:45'), findsOneWidget); // Shows only minutes:seconds
    });

    testWidgets('should have play/pause button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration(minutes: 3, seconds: 45)),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('should toggle play/pause button state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration(minutes: 3, seconds: 45)),
          ),
        ),
      );

      // Initially shows play button
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);

      // Tap the play button
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();

      // Now shows pause button
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('should have navigation buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration(minutes: 3, seconds: 45)),
          ),
        ),
      );

      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    });

    testWidgets('should have slider with correct max value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: Duration(minutes: 3, seconds: 45)),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.max, 225.0); // 3 minutes 45 seconds = 225 seconds
    });

    testWidgets('should have slider with default max when duration is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Controls(duration: null),
          ),
        ),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.max, 100.0); // Default max value
    });
  });

  group('Duration Formatting Tests', () {
    test('should format duration correctly', () {
      final controls = _ControlsTestHelper();

      expect(controls.formatDuration(null), '0:00');
      expect(controls.formatDuration(Duration.zero), '00:00');
      expect(controls.formatDuration(Duration(seconds: 30)), '00:30');
      expect(
          controls.formatDuration(Duration(minutes: 1, seconds: 30)), '01:30');
      expect(
          controls.formatDuration(Duration(minutes: 10, seconds: 5)), '10:05');
      expect(
          controls.formatDuration(Duration(minutes: 59, seconds: 59)), '59:59');
      expect(
          controls.formatDuration(Duration(hours: 1, minutes: 23, seconds: 45)),
          '23:45');
    });
  });
}

// Helper class to test private methods
class _ControlsTestHelper {
  String formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
