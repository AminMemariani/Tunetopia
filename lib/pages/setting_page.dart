import 'package:flutter/material.dart';

import '../constants/style.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isDarkMode = false;
  @override
  void initState() {
    Future.delayed(const Duration(microseconds: 0), () {
      _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    });
    super.initState();
  }

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
                        _isDarkMode = value;
                        setState(() {
                          Theme.of(context).copyWith(primaryColor: Colors.red);
                        });
                      },
                      value: _isDarkMode,
                    ),
                  ],
                )),
      ),
    );
  }
}
