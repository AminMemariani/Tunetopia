import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_player/utils/duration_formatter.dart';
import 'dart:async';

class Controls extends StatefulWidget {
  final Duration? duration;
  final String? filePath;

  const Controls({super.key, this.duration, this.filePath});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  AudioPlayer? _audioPlayer;
  Timer? _positionTimer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // Listen to position changes
    _positionSubscription = _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Listen to player state changes
    _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = false; // We'll handle loading state differently
        });
      }
    });
  }

  Future<void> _playPause() async {
    if (_audioPlayer == null || widget.filePath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          // First time playing, load the file
          await _audioPlayer!.play(DeviceFileSource(widget.filePath!));
        } else {
          // Resume from current position
          await _audioPlayer!.resume();
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> _stop() async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.stop();
      setState(() {
        _currentPosition = Duration.zero;
      });
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  String _formatDuration(Duration? duration) {
    return DurationFormatter.formatDuration(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_formatDuration(_currentPosition)),
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
                    max: _totalDuration.inSeconds.toDouble() > 0
                        ? _totalDuration.inSeconds.toDouble()
                        : (widget.duration?.inSeconds.toDouble() ?? 100.0),
                    value: _currentPosition.inSeconds.toDouble(),
                    onChanged: (double value) {
                      final newPosition = Duration(seconds: value.toInt());
                      _seekTo(newPosition);
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_formatDuration(_totalDuration.inSeconds > 0
                  ? _totalDuration
                  : widget.duration)),
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
                _stop();
              },
              iconSize: 40,
            ),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 30,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : IconButton(
                      icon: _isPlaying
                          ? const Icon(Icons.pause_rounded)
                          : const Icon(Icons.play_arrow_rounded),
                      onPressed: _playPause,
                      iconSize: 40,
                    ),
            ),
            IconButton(
              icon: const Icon(Icons.stop_rounded),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                _stop();
              },
              iconSize: 40,
            ),
          ],
        ),
      ],
    );
  }
}
