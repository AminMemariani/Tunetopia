import 'package:flutter/material.dart';
import 'package:music_player/pages/widgets/my_drawer.dart';

import '../widgets/home_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FMP"),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, "songs"),
              child: HomeItem())),
    );
  }
}
