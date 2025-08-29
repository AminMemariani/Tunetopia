import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/utils/duration_formatter.dart';

void main() {
  group('DurationFormatter Tests', () {
    group('formatDuration', () {
      test('should format null duration as 0:00', () {
        expect(DurationFormatter.formatDuration(null), '0:00');
      });

      test('should format zero duration as 0:00', () {
        expect(DurationFormatter.formatDuration(Duration.zero), '0:00');
      });

      test('should format seconds correctly', () {
        expect(DurationFormatter.formatDuration(Duration(seconds: 30)), '0:30');
        expect(DurationFormatter.formatDuration(Duration(seconds: 59)), '0:59');
      });

      test('should format minutes and seconds correctly', () {
        expect(DurationFormatter.formatDuration(Duration(seconds: 70)), '1:10');
        expect(
            DurationFormatter.formatDuration(Duration(seconds: 125)), '2:05');
        expect(
            DurationFormatter.formatDuration(Duration(minutes: 5, seconds: 45)),
            '5:45');
      });

      test('should format hours, minutes and seconds correctly', () {
        expect(DurationFormatter.formatDuration(Duration(seconds: 3661)),
            '1:01:01');
        expect(
            DurationFormatter.formatDuration(
                Duration(hours: 2, minutes: 30, seconds: 15)),
            '2:30:15');
        expect(
            DurationFormatter.formatDuration(
                Duration(hours: 1, minutes: 0, seconds: 30)),
            '1:00:30');
      });

      test('should handle edge cases', () {
        expect(DurationFormatter.formatDuration(Duration(milliseconds: 500)),
            '0:00');
        expect(DurationFormatter.formatDuration(Duration(seconds: 1)), '0:01');
        expect(DurationFormatter.formatDuration(Duration(minutes: 1)), '1:00');
        expect(DurationFormatter.formatDuration(Duration(hours: 1)), '1:00:00');
      });
    });

    group('formatSeconds', () {
      test('should format null seconds as 0:00', () {
        expect(DurationFormatter.formatSeconds(null), '0:00');
      });

      test('should format seconds correctly', () {
        expect(DurationFormatter.formatSeconds(30), '0:30');
        expect(DurationFormatter.formatSeconds(70), '1:10');
        expect(DurationFormatter.formatSeconds(125), '2:05');
        expect(DurationFormatter.formatSeconds(3661), '1:01:01');
      });

      test('should handle zero seconds', () {
        expect(DurationFormatter.formatSeconds(0), '0:00');
      });
    });
  });
}
