import 'package:flutter/material.dart';

import 'package:music_player/pages/widgets/my_drawer.dart';

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
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Padding(padding: const EdgeInsets.all(12), child: HomeItem()),
    );
  }
}
