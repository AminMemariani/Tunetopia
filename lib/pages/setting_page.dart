import 'package:flutter/material.dart';

import '../constants/style.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
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
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          value
                              ? _toggleTheme(ThemeMode.dark)
                              : _toggleTheme(ThemeMode.light);
                        });
                       // _themeMode = value;
                      },
                    ),
                  ],
                )),
      ),
    );
  }
}
