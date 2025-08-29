import 'dart:io';

import 'package:cached_memory_image/cached_memory_image.dart';
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
  bool _isLoadingMetadata = false;

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
    
    // Load metadata if not already loading
    if (!_isLoadingMetadata) {
      _isLoadingMetadata = true;
      context.read<Songs>().loadImage(song!).then((_) {
        if (mounted) {
          setState(() {
            _isLoadingMetadata = false;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MyAppBar(
        title: song?.songName ?? "No Name",
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.info_outline_rounded))
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
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
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: song?.songImage == null
                                ? const Icon(Icons.music_note_rounded)
                                : CachedMemoryImage(
                                    uniqueKey: 'app://image/1',
                                    errorWidget: const Text('Error'),
                                    base64: song!.songImage.toString(),
                                    placeholder:
                                        const CircularProgressIndicator
                                        .adaptive(),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Controls(
                duration: song?.duration,
                filePath: song?.filePath,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
