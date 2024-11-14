import 'package:flutter/material.dart';

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
          color: Colors.amber,
          child: const DrawerHeader(
            child: Text(""),
          ),
        ),
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings),
          onTap: () {
            Navigator.of(context).pushNamed("settings");
          },
        ),
      ],
    ));
  }
}
