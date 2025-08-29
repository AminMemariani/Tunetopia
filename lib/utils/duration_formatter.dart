class DurationFormatter {
  /// Formats a Duration to a readable string format
  /// Examples:
  /// - 30 seconds → "0:30"
  /// - 70 seconds → "1:10"
  /// - 125 seconds → "2:05"
  /// - 3661 seconds → "1:01:01"
  static String formatDuration(Duration? duration) {
    if (duration == null) return "0:00";

    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      // Format: H:MM:SS (e.g., "1:01:01")
      return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      // Format: M:SS (e.g., "1:10")
      return "$minutes:${seconds.toString().padLeft(2, '0')}";
    }
  }

  /// Formats duration in seconds to a readable string format
  /// Examples:
  /// - 30 → "0:30"
  /// - 70 → "1:10"
  /// - 125 → "2:05"
  /// - 3661 → "1:01:01"
  static String formatSeconds(int? seconds) {
    if (seconds == null) return "0:00";
    return formatDuration(Duration(seconds: seconds));
  }
}
