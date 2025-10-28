import 'dart:convert';
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

  void _showSongInfoDialog() {
    if (song == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Song Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Title', song!.songName),
                _buildInfoRow('Artist', song!.songArtist ?? 'Unknown Artist'),
                _buildInfoRow('Album', song!.songAlbum ?? 'Unknown Album'),
                _buildInfoRow('Duration', _formatDuration(song!.duration)),
                _buildInfoRow('File Path', song!.filePath ?? 'Unknown'),
                _buildInfoRow('File Size', _getFileSizeString()),
                _buildInfoRow(
                    'Has Cover Art', song!.songImage != null ? 'Yes' : 'No'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Unknown';

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  String _getFileSizeString() {
    if (song?.filePath == null) return 'Unknown';

    try {
      final file = File(song!.filePath!);
      if (file.existsSync()) {
        final size = file.lengthSync();
        return _formatFileSize(size);
      }
    } catch (e) {
      debugPrint('Error getting file size: $e');
    }

    return 'Unknown';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildCoverArt(Size size) {
    // Check if we have image data
    final hasImage = song?.songImage != null && song!.songImage!.isNotEmpty;

    // If we have an image, show it immediately
    if (hasImage) {
      return CachedMemoryImage(
        uniqueKey: 'app://image/${song!.filePath}',
        errorWidget: _buildReplacementIcon(size),
        base64: base64Encode(song!.songImage!),
      );
    }

    // Show loading indicator only if actively loading metadata
    if (_isLoadingMetadata) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const CircularProgressIndicator.adaptive(),
      );
    }
    
    // Show replacement icon if no image is available and not loading
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size.width * 0.15,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildReplacementIcon(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size.width * 0.15,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
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
      // Set the current song in the Songs provider
      final song = ModalRoute.of(context)?.settings.arguments as Song?;
      if (song != null) {
        context.read<Songs>().setCurrentSong(song);
      }
    });

    super.initState();
  }
  
  Future<void> _loadMetadataIfNeeded() async {
    if (song == null) return;

    // Only load metadata if image is not already loaded
    if (_fileExists &&
        !_isLoadingMetadata &&
        (song!.songImage == null || song!.songImage!.isEmpty)) {
      setState(() {
        _isLoadingMetadata = true;
      });

      try {
        await context.read<Songs>().loadImage(song!);
        // Force rebuild after loading image
        if (mounted) {
          setState(() {});
        }
      } catch (error) {
        debugPrint('Error loading image metadata: $error');
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingMetadata = false;
          });
        }
      }
    }
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
          } else if (exists) {
            // Load metadata after confirming file exists
            _loadMetadataIfNeeded();
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
    song = ModalRoute.of(context)?.settings.arguments as Song?;
    final size = MediaQuery.of(context).size;
    
    // Handle null song
    if (song == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: MyAppBar(
          title: "No Song Selected",
          actions: [
            IconButton(
              onPressed: _showSongInfoDialog,
              icon: const Icon(Icons.info_outline_rounded),
            )
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_off, size: 64),
              SizedBox(height: 16),
              Text('No song selected'),
            ],
          ),
        ),
      );
    }
    
    // Show loading or file not found state
    if (_isCheckingFile) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: MyAppBar(
          title: song?.songName ?? "No Name",
          actions: [
            IconButton(
              onPressed: _showSongInfoDialog,
              icon: const Icon(Icons.info_outline_rounded),
            )
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
          actions: [
            IconButton(
              onPressed: _showSongInfoDialog,
              icon: const Icon(Icons.info_outline_rounded),
            )
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
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MyAppBar(
        title: song?.songName ?? "No Name",
        actions: [
          IconButton(
            onPressed: _showSongInfoDialog,
            icon: const Icon(Icons.info_outline_rounded),
          )
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
                            child: _buildCoverArt(size),
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
