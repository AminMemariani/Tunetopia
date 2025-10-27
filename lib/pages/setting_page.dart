import 'package:flutter/material.dart';
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
        title: Text("Settings", style: MyStyles.getAppTextStyle(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, i) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dark Mode", style: MyStyles.getAppTextStyle(context)),
                    Switch.adaptive(
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                      value: context.watch<ThemeProvider>().isDarkMode,
                    ),
                  ],
                )),
      ),
    );
  }
}
