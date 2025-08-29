import 'package:flutter/material.dart';
import 'package:music_player/constants/style.dart';

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
          child: const DrawerHeader(
            child: Text("Tunetopia"),
          ),
        ),
        ListTile(
          title: const Text(
            'Settings',
            style: MyStyles.appTextStyle,
          ),
          leading: const Icon(Icons.settings),
          onTap: () {
            Navigator.of(context).pushNamed("settings");
          },
        ),
      ],
    ));
  }
}
