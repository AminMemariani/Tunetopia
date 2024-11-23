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
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Start time"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor:
                            Theme.of(context).colorScheme.secondary,
                        trackShape: const RoundedRectSliderTrackShape(),
                        overlayShape: SliderComponentShape.noOverlay,
                        trackHeight: 3.0,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7.0, elevation: 0),
                        overlayColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: const Slider(
                          min: 0.0,
                          /* max: _duration.inSeconds.toDouble() == 0
                            ? 1.0
                            : _duration.inSeconds.toDouble(), */
                          max: 100,
                          //value: _position.inSeconds.toDouble(),
                          value: 0,
                          onChanged: /* (double val) async {
                          final pos = Duration(seconds: val.toInt());
                          await player.seek(pos); */
                              null),
                    ),
                  ),
                ),
                Text("End time"),
              ],
            ),
          ),
          Row(
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
        ],
      ),
    );
  }
}
