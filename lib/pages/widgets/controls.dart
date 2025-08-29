import 'package:flutter/material.dart';

class Controls extends StatefulWidget {
  final Duration? duration;

  const Controls({super.key, this.duration});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  bool _isPlaying = false;
  
  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("0:00"),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(context).colorScheme.secondary,
                  trackShape: const RoundedRectSliderTrackShape(),
                  overlayShape: SliderComponentShape.noOverlay,
                  trackHeight: 3.0,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7.0, elevation: 0),
                  overlayColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Slider(
                    min: 0.0,
                    max: widget.duration?.inSeconds.toDouble() ?? 100.0,
                    value: 0,
                    onChanged: /* (double val) async {
                    final pos = Duration(seconds: val.toInt());
                    await player.seek(pos); */
                        null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_formatDuration(widget.duration)),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                // Add play functionality here
              },
              iconSize: 40,
            ),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 30,
              child: IconButton(
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
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                // Add stop functionality here
              },
              iconSize: 40,
            ),
          ],
        ),
      ],
    );
  }
}
