import 'dart:io';

import 'package:flutter/material.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music_player/pages/widgets/appbar.dart';
import 'package:music_player/pages/widgets/controls.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  Song? song;

  _asyncMethod() async {
    final hasStorageAccess =
        Platform.isAndroid ? await Permission.storage.isGranted : true;
    if (!hasStorageAccess) {
      await Permission.storage.request();
      if (!await Permission.storage.isGranted) {
        return;
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });

    super.initState();
  }

  Future<void> loadMetadata(String file) async{
    Metadata metadata = await MetadataGod.readMetadata(file: file);
  }

  @override
  Widget build(BuildContext context) {
    song = ModalRoute.of(context)?.settings.arguments as Song;
      

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MyAppBar(title: song!.songName),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: const BoxDecoration(
/*                 image: DecorationImage(
                  image:  AssetImage(
                      'assets/cover_image.png'), // Add your cover image here 
                  fit: BoxFit.cover,
                ), */
                  ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Controls(),
          )
        ],
      ),
    );
  }
}
