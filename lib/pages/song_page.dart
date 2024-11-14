import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player/pages/widgets/controls.dart';
import 'package:permission_handler/permission_handler.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: const Text("Song Name")),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/cover_image.png'), // Add your cover image here
                  fit: BoxFit.cover,
                ),
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
