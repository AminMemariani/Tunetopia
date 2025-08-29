import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music_player/models/song.dart';

class Songs with ChangeNotifier {
  final List<Song?> _songs = [];

  Song? findByName(String name) {
    return _songs.firstWhere((sng) => sng?.songName == name);
  }

  List<Song?> get songs {
    return [..._songs];
  }

  Future<void> addSongs(String files) async {
    RegExp regex = RegExp(r"PlatformFile\(path ([^,]*)");

    Iterable<Match?> matches = regex.allMatches(files);

    if (matches.isNotEmpty) {
      for (Match? match in matches) {
        _songs.add(Song(
            songName: match!.group(1)!.trim().split('/').last,
            filePath: match.group(1)!.trim()));
      }

      notifyListeners();
    } else {
      debugPrint("Filename not found.");
    }
  }

  Future<void> loadImage(Song song) async {
    try {
      Metadata metadata =
          await MetadataGod.readMetadata(file: song.filePath.toString());
      
      // Extract image if available
      if (song.filePath != "" && metadata.picture?.data != null) {
        song.songImage = metadata.picture!.data;
      }
      
      // Extract duration from metadata
      if (metadata.duration != null) {
        song.duration = metadata.duration;
        song.notifyListeners(); // Notify listeners that the song has been updated
      }
    } catch (e) {
      debugPrint("File Path: ${song.filePath}");
      debugPrint("Error loading metadata: $e");
    }
  }
}
