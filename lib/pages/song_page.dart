import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player/pages/widgets/appBar.dart';
import 'package:music_player/providers/songs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import 'widgets/controls.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  Song? song;
  Future? metadataFuture;

  Future _obtainSong() {
    return Provider.of<Songs>(context, listen: false)
        .loadImage(song?.filePath ?? "");
  }

  _asyncMethod() async {
    metadataFuture = _obtainSong();
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

  @override
  Widget build(BuildContext context) {
    song = ModalRoute.of(context)?.settings.arguments as Song;

    return FutureBuilder(
        future: metadataFuture,
        builder: (ctx, snapshot) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: MyAppBar(title: song!.songName),
            body: Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Container(
                    child: snapshot.data,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Controls(),
                )
              ],
            ),
          );
        });
  }
}
