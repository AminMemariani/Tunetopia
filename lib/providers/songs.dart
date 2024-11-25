import 'package:flutter/foundation.dart';

class Songs with ChangeNotifier {
  final List<String> songs = [];

  Future<void> addSongs(String files) async {
    RegExp regex = RegExp(r"name: ([^,]+)");

    Iterable<Match?> matches = regex.allMatches(files);
    List<String> filenames = [];

    if (matches.isNotEmpty) {
      for (Match? match in matches) {
        filenames.add(match!.group(1)!.trim());
      }
      songs.addAll(filenames);
      for (String song in songs) {
        debugPrint(song);
        notifyListeners();
      }
    } else {
      print("Filename not found.");
    }
  }
}
