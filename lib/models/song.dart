import 'package:flutter/foundation.dart';

class Song with ChangeNotifier {
  Uint8List? songImage;
  String songName;
  String? songArtist;
  String? filePath;
  String? songAlbum;
  Duration? duration;
  
  Song({
    required this.songName,
    this.filePath,
    this.songArtist,
    this.songImage,
    this.songAlbum,
    this.duration,
  });
}
