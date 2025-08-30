import 'package:flutter/material.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music_player/data/app_database.dart';
import 'package:music_player/pages/home.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:music_player/providers/songs.dart';
import 'package:music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'pages/setting_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MetadataGod.initialize();
  
  // Initialize all databases
  await AppDatabase.initialize();
  
  // Initialize the Songs provider to set up the database
  final songsProvider = Songs();
  await songsProvider.initialize();
  
  // Initialize the Theme provider to load saved theme preference
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  runApp(ChangeNotifierProvider.value(
    value: themeProvider,
    child: MyApp(songsProvider: songsProvider),
  ));
}

class MyApp extends StatelessWidget {
  final Songs songsProvider;

  const MyApp({super.key, required this.songsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: songsProvider,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tunetopia',
            theme: themeProvider.themeData,
            home: const HomePage(),
            initialRoute: "home",
            routes: {
              "home": (ctx) => const HomePage(),
              "songs": (ctx) => const SongPage(),
              "settings": (ctx) => const SettingPage()
            },
          );
        },
      ),
    );
  }
}
