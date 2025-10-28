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
            'Clean Up Missing Files',
            style: MyStyles.getAppTextStyle(context),
          ),
          leading: const Icon(Icons.cleaning_services),
          onTap: () async {
            Navigator.of(context).pop(); // Close drawer
            await context.read<Songs>().cleanupMissingFiles();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Missing files have been cleaned up'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        ListTile(
          title: Text(
            'Clear All Songs (Debug)',
            style: MyStyles.getAppTextStyle(context),
          ),
          leading: const Icon(Icons.delete_forever),
          onTap: () async {
            Navigator.of(context).pop(); // Close drawer
            await context.read<Songs>().clearAllSongs();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All songs cleared from database'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    ));
  }
}
