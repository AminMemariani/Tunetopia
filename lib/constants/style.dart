import 'package:flutter/material.dart';

class MyStyles {
  const MyStyles();
  static const TextStyle title = TextStyle(fontFamily: "Pacifico");
  static const TextStyle appTextStyle = TextStyle(fontFamily: "Nunito");
  static const Text appName = Text("Tunetopia ", style: title);

    static final lightTheme = ThemeData(
    primaryColor: Colors.amber,
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    primaryColor: Colors.amber,
    brightness: Brightness.dark,
  );
}
