import 'package:flutter/material.dart';
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

  updateSongs() {}

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

  Future<Widget> loadImage(String file) async {
      Metadata metadata = await MetadataGod.readMetadata(file: file);
    if (file != "" || metadata.picture?.data != null) {
      return Image.memory(metadata.picture!.data);
    } else {
      return const Icon(Icons.music_note_rounded);
    }
  }
}
