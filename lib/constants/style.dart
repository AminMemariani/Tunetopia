import 'package:flutter/material.dart';

class MyStyles {
  static const TextStyle title = TextStyle(fontFamily: "Pacifico");
  static const TextStyle appTextStyle = TextStyle(fontFamily: "Nunito");
  static const Text appName = Text("Tunetopia ", style: title);
  
  // Theme-aware text styles
  static TextStyle getAppTextStyle(BuildContext context) {
    return TextStyle(
      fontFamily: "Nunito",
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
      fontFamily: "Pacifico",
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
