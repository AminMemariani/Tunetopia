import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:music_player/pages/widgets/my_drawer.dart';
import 'package:music_player/providers/songs.dart';
import 'package:provider/provider.dart';

import 'widgets/home_item.dart';
import '../constants/style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: MyStyles.appName,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['mp3', 'wav', 'ogg', 'aac'],
                );
                //debugPrint("result: ${result.toString()}");
                if (context.mounted) {
                  context.read<Songs>().addSongs(result.toString());
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const MyDrawer(),
      body: const HomeItem(),
    );
  }
}
