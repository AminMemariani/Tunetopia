import 'package:flutter/material.dart';

import '../constants/style.dart';

class SettingPage extends StatefulWidget {

  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true,
        title: const Text("Settings" , style: MyStyles.appTextStyle),
      ),
    );
  }
}
