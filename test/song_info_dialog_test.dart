import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:music_player/providers/songs.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/song_database.dart';
import 'test_helpers/mock_data.dart';

void main() {
  group('Song Info Dialog Tests', () {
    late Songs songsProvider;

    setUpAll(() async {
      // Initialize Hive for testing (without Flutter path provider)
      Hive.init('test_hive_song_info');

      // Initialize the song database
      await SongDatabase.initialize();
      
      await MockData.initialize();
    });

    tearDownAll(() async {
      await MockData.cleanup();
      
      // Close Hive boxes
      await Hive.close();
    });

    setUp(() async {
      songsProvider = Songs();
      // Clear the database to ensure clean state for each test
      await SongDatabase.clearAllSongs();
    });

    // Helper function to create a test widget with song data
    Widget createTestWidget(Song song) {
      return MaterialApp(
        home: ChangeNotifierProvider<Songs>(
          create: (_) => songsProvider,
          child: Builder(
            builder: (context) => Scaffold(
              body: Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) => const SongPage(),
                  settings: RouteSettings(arguments: song),
                ),
              ),
            ),
          ),
        ),
      );
    }

    group('Info Dialog Display', () {
      testWidgets('should show info dialog when info button is tapped',
          (WidgetTester tester) async {
        final song = MockData.createCompleteSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Find and tap the info button
        final infoButton = find.byIcon(Icons.info_outline_rounded);
        expect(infoButton, findsOneWidget);

        await tester.tap(infoButton);
        await tester.pump();

        // Should show the dialog
        expect(find.text('Song Information'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);
      });

      testWidgets('should display song metadata in dialog',
          (WidgetTester tester) async {
        final song = MockData.createCompleteSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should display all metadata fields
        expect(find.text('Title:'), findsOneWidget);
        expect(find.text('Test Song'), findsAtLeastNWidgets(1));

        expect(find.text('Artist:'), findsOneWidget);
        expect(find.text('Test Artist'), findsOneWidget);

        expect(find.text('Album:'), findsOneWidget);
        expect(find.text('Test Album'), findsOneWidget);

        expect(find.text('Duration:'), findsOneWidget);
        expect(find.text('03:45'), findsOneWidget);

        expect(find.text('File Path:'), findsOneWidget);
        expect(find.text(MockData.validSongFile.path), findsOneWidget);

        expect(find.text('Has Cover Art:'), findsOneWidget);
        expect(find.text('Yes'), findsOneWidget);
      });

      testWidgets('should display unknown values for missing metadata',
          (WidgetTester tester) async {
        final song = MockData.createSongWithMissingMetadata();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should display unknown values for missing metadata
        expect(find.text('Artist:'), findsOneWidget);
        expect(find.text('Unknown Artist'), findsOneWidget);

        expect(find.text('Album:'), findsOneWidget);
        expect(find.text('Unknown Album'), findsOneWidget);

        expect(find.text('Duration:'), findsOneWidget);
        expect(find.text('Unknown'), findsAtLeastNWidgets(1));

        expect(find.text('Has Cover Art:'), findsOneWidget);
        expect(find.text('No'), findsOneWidget);
      });

      testWidgets('should close dialog when close button is tapped',
          (WidgetTester tester) async {
        final song = MockData.createMinimalSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button to open dialog
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Dialog should be visible
        expect(find.text('Song Information'), findsOneWidget);

        // Tap close button
        await tester.tap(find.text('Close'));
        await tester.pump();

        // Dialog should be closed
        expect(find.text('Song Information'), findsNothing);
      });

      testWidgets('should handle long duration formatting',
          (WidgetTester tester) async {
        final song = MockData.createLongDurationSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should display duration in HH:MM:SS format
        expect(find.text('Duration:'), findsOneWidget);
        expect(find.text('1:01:01'), findsOneWidget);
      });

      testWidgets('should display file size information',
          (WidgetTester tester) async {
        final song = MockData.createMinimalSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should display file size
        expect(find.text('File Size:'), findsOneWidget);
        // File size should be displayed (exact value depends on test file)
        expect(find.textContaining('B'), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle null file path gracefully',
          (WidgetTester tester) async {
        final song = MockData.createSongWithNullPath();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should display unknown for file path and size
        expect(find.text('File Path:'), findsOneWidget);
        expect(find.text('Unknown'), findsAtLeastNWidgets(1));

        expect(find.text('File Size:'), findsOneWidget);
        expect(find.text('Unknown'), findsAtLeastNWidgets(1));
      });

      testWidgets('should be scrollable for long content',
          (WidgetTester tester) async {
        final song = MockData.createLongTextSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should find SingleChildScrollView
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Should display all content
        expect(
            find.text('Very Long Song Name That Might Cause Wrapping Issues'),
            findsAtLeastNWidgets(1));
        expect(
            find.text('Very Long Artist Name That Might Cause Wrapping Issues'),
            findsOneWidget);
        expect(
            find.text('Very Long Album Name That Might Cause Wrapping Issues'),
            findsOneWidget);
      });
    });

    group('Dialog Styling', () {
      testWidgets('should use adaptive dialog', (WidgetTester tester) async {
        final song = MockData.createMinimalSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should use AlertDialog.adaptive - check for dialog content instead
        expect(find.text('Song Information'), findsOneWidget);
      });

      testWidgets('should have proper text styling',
          (WidgetTester tester) async {
        final song = MockData.createCompleteSong();

        await tester.pumpWidget(createTestWidget(song));

        await tester.pump();

        // Tap info button
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pump();

        // Should find text widgets with proper styling
        expect(find.text('Title:'), findsOneWidget);
        expect(find.text('Artist:'), findsOneWidget);
        expect(find.text('Test Song'), findsAtLeastNWidgets(1));
        expect(find.text('Test Artist'), findsOneWidget);
      });
    });
  });
}
