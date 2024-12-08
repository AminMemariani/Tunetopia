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

class _SongPageState extends State<SongPage>
    with SingleTickerProviderStateMixin {
  Song? song;
  Future? metadataFuture;
  late AnimationController _controller;
  late Animation<double> _animation;

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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    song = ModalRoute.of(context)?.settings.arguments as Song;
    final size = MediaQuery.of(context).size;

    return FutureBuilder(
        future: metadataFuture,
        builder: (ctx, snapshot) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: MyAppBar(title: song?.songName ?? "No Name"),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Hero(
                              tag: song!.filePath.toString(),
                              child: Container(
                                width: size.width * 0.45,
                                height: size.width * 0.45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: snapshot.data ??
                                      Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        child: Icon(
                                          Icons.music_note,
                                          size: 80,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Controls(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
  }
}
