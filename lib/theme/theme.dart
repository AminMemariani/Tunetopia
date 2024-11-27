import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color.fromARGB(255, 238, 238, 238),
    primary: Colors.amber,
    secondary: Colors.white70,
    tertiary: Color.fromARGB(255, 86, 86, 86),
  ),
);
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.deepPurple,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey,
  ),
);
