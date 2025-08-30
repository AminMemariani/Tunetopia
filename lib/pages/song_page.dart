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
  bool _isCheckingFile = false;
  bool _fileExists = true;

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

  Future<bool> _checkFileExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;

    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  void _showFileNotFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('File Not Found'),
          content: const Text(
            'The song file is no longer available on your device. '
            'It may have been moved or deleted.\n\n'
            'The song will be removed from your library.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop(); // Close dialog

                // Remove song from database and provider
                if (song != null) {
                  await context.read<Songs>().removeSongFromLibrary(song!);
                }

                if (mounted) {
                  navigator.pop(); // Go back to home page
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
      _checkSongFile();
    });

    super.initState();
  }

  Future<void> _checkSongFile() async {
    if (_isCheckingFile) return;

    setState(() {
      _isCheckingFile = true;
    });

    try {
      final song = ModalRoute.of(context)?.settings.arguments as Song?;
      if (song != null) {
        final exists = await _checkFileExists(song.filePath);
        if (mounted) {
          setState(() {
            _fileExists = exists;
            _isCheckingFile = false;
          });

          if (!exists && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showFileNotFoundDialog();
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking song file: $e');
      if (mounted) {
        setState(() {
          _isCheckingFile = false;
        });
      }
    }
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
    
    // Show loading or file not found state
    if (_isCheckingFile) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: MyAppBar(
          title: song?.songName ?? "No Name",
          actions: const [
            IconButton(onPressed: null, icon: Icon(Icons.info_outline_rounded))
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking file availability...'),
            ],
          ),
        ),
      );
    }

    // Show file not found state
    if (!_fileExists) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: MyAppBar(
          title: song?.songName ?? "No Name",
          actions: const [
            IconButton(onPressed: null, icon: Icon(Icons.info_outline_rounded))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'File Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'The song file is no longer available on your device.\nIt may have been moved or deleted.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  // Remove song from database and provider
                  if (song != null) {
                    await context.read<Songs>().removeSongFromLibrary(song!);
                  }
                  if (mounted) {
                    navigator.pop();
                  }
                },
                child: const Text('Go Back to Home'),
              ),
            ],
          ),
        ),
      );
    }
    
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
