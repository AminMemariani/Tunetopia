import 'package:flutter/material.dart';
import 'package:music_player/theme/theme.dart';
import 'package:music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text("Settings", style: MyStyles.appTextStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, i) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dark Mode"),
                    Switch.adaptive(
                      onChanged: (value) {
                        setState(() {
                          context.read<ThemeProvider>().toggleTheme();
                        });
                      },
                      value:
                          context.read<ThemeProvider>().themeData == lightMode
                              ? false
                              : true,
                    ),
                  ],
                )),
      ),
    );
  }
}
