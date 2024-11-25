import 'package:flutter/foundation.dart';

class Songs with ChangeNotifier {
  final List<String> songs = ["11111", "222222", "3333333"];

  Future<void> addSongs(String files) async {
    RegExp regex = RegExp(r"name: ([^\s,]+)");
    Match? match = regex.firstMatch(files);
    if (match != null) {
      String filename = match.group(1)!;
      print(filename); // Output: hope.mp3
    } else {
      print("Filename not found.");
    }
  }
}
