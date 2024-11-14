import 'package:flutter/material.dart';
import 'package:music_player/pages/home.dart';
import 'package:music_player/pages/song_page.dart';

import 'pages/setting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomePage(),
      initialRoute: "home",
      routes: {
        "home": (ctx) => const HomePage(),
        "songs": (ctx) => const SongPage(),
        "settings": (ctx) => const SettingPage()
      },
    );
  }
}
