import 'package:flutter/material.dart';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  bool _isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            onPressed: () {
              // Add play functionality here
            },
            iconSize: 40,
          ),
          IconButton(
            icon: _isPlaying
                ? const Icon(Icons.pause_rounded)
                : const Icon(Icons.play_arrow_rounded),
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
              // Add pause functionality here
            },
            iconSize: 40,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: () {
              // Add stop functionality here
            },
            iconSize: 40,
          ),
        ],
      ),
    );
  }
}
