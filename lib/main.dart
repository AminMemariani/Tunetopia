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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      initialRoute: HomePage.route,
      routes: {
        SongPage.route: (ctx) => const SongPage(),
        SettingPage.route: (ctx) => const SettingPage()
      }
      ,
    );
  }
}
