import 'package:flutter/foundation.dart';
import 'package:music_player/models/song.dart';

class Songs with ChangeNotifier {
  final List<Song> _songs = [];

  Song? findByName(String name) {
    return _songs.firstWhere((sng) => sng.songName == name);
  }

  List<Song> get songs {
    return [..._songs];
  }

  Future<void> addSongs(String files) async {
    RegExp regex = RegExp(r"name: ([^,]+)");

    Iterable<Match?> matches = regex.allMatches(files);
    List<String> filenames = [];

    if (matches.isNotEmpty) {
      for (Match? match in matches) {
        filenames.add(match!.group(1)!.trim());
      }
      notifyListeners();
    } else {
      debugPrint("Filename not found.");
    }
  }
}
