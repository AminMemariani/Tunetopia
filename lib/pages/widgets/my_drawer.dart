import 'package:flutter/material.dart';
import 'package:music_player/constants/style.dart';
import 'package:music_player/providers/songs.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 100,
          color: Theme.of(context).colorScheme.primary,
          child: DrawerHeader(
            child: Text("Tunetopia", style: MyStyles.getTitleStyle(context)),
          ),
        ),
        ListTile(
          title: Text(
            'Settings',
            style: MyStyles.getAppTextStyle(context),
          ),
          leading: const Icon(Icons.settings),
          onTap: () {
            Navigator.of(context).pushNamed("settings");
          },
        ),
        ListTile(
          title: Text(
            'Sync files',
            style: MyStyles.getAppTextStyle(context),
          ),
          leading: const Icon(Icons.sync),
          onTap: () async {
            Navigator.of(context).pop(); // Close drawer
            final removed = await context.read<Songs>().cleanupMissingFiles();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sync complete. Removed $removed missing file(s).'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    ));
  }
}
