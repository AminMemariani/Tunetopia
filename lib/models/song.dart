import 'package:flutter/material.dart';

class Song with ChangeNotifier {
  int songId;
  String? songImage;
  String songName;
  String? songArtist;
  String? songAlbum;
  Song({
    required this.songId,
    required this.songName,
    this.songArtist,
    this.songImage,
    this.songAlbum,
  });
}
