import 'package:flutter/foundation.dart';
import 'package:music_player/models/song.dart';

class Songs with ChangeNotifier {
  final List<Song?> _songs = [];

  Song? findByName(String name) {
    return _songs.firstWhere((sng) => sng?.songName == name);
  }

  List<Song?> get songs {
    return [..._songs];
  }

  updateSongs() {}

  Future<void> addSongs(String files) async {
    RegExp regex = RegExp(r"name: ([^,]+)");

    Iterable<Match?> matches = regex.allMatches(files);

    if (matches.isNotEmpty) {
      for (Match? match in matches) {
        _songs.add(Song(songName: match!.group(1)!.trim(), filePath: ""));
      }

      notifyListeners();
    } else {
      debugPrint("Filename not found.");
    }
  }
}
