import 'package:flutter/material.dart';
import 'package:music_player/pages/home.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'pages/setting_page.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: context.watch<ThemeProvider>().themeData,
      themeMode: ThemeMode.system,
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
