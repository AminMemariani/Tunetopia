import 'package:flutter/material.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music_player/pages/home.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:music_player/providers/songs.dart';
import 'package:music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import 'pages/setting_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MetadataGod.initialize();
  
  // Initialize the Songs provider to set up the database
  final songsProvider = Songs();
  await songsProvider.initialize();
  
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
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
      child: MaterialApp(
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
      ),
    );
  }
}
