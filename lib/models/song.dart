import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 0)
class Song with ChangeNotifier {
  @HiveField(0)
  Uint8List? songImage;
  
  @HiveField(1)
  String songName;
  
  @HiveField(2)
  String? songArtist;
  
  @HiveField(3)
  String? filePath;
  
  @HiveField(4)
  String? songAlbum;
  
  @HiveField(5)
  int? durationInSeconds; // Store duration as seconds for Hive compatibility
  
  Song({
    required this.songName,
    this.filePath,
    this.songArtist,
    this.songImage,
    this.songAlbum,
    this.durationInSeconds,
  });
  
  // Getter for duration
  Duration? get duration {
    return durationInSeconds != null
        ? Duration(seconds: durationInSeconds!)
        : null;
  }

  // Setter for duration
  set duration(Duration? value) {
    durationInSeconds = value?.inSeconds;
  }
}
