import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_player/utils/duration_formatter.dart';
import 'package:music_player/providers/songs.dart';
import 'package:music_player/models/song.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Controls extends StatefulWidget {
  final Duration? duration;
  final String? filePath;
  final ValueChanged<PlayMode>? onPlayModeChanged;

  const Controls(
      {super.key, this.duration, this.filePath, this.onPlayModeChanged});

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
  PlayMode _playMode = PlayMode.shuffle;

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

    // Listen to player completion
    _audioPlayer!.onPlayerComplete.listen((_) {
      _handleSongCompletion();
    });
  }

  void _handleSongCompletion() {
    final songsProvider = context.read<Songs>();

    switch (_playMode) {
      case PlayMode.repeatOne:
        // Restart the same song
        _restartCurrentSong();
        break;
      case PlayMode.shuffle:
      case PlayMode.repeatAll:
        // Move to next song
        final nextSong = songsProvider.getNextSong();
        if (nextSong != null) {
          _playNextSong(nextSong);
        }
        break;
    }
  }

  void _restartCurrentSong() {
    if (_audioPlayer != null && widget.filePath != null) {
      _audioPlayer!.seek(Duration.zero);
      _audioPlayer!.resume();
    }
  }

  void _playNextSong(Song nextSong) {
    // Navigate to the next song
    Navigator.pushReplacementNamed(context, "songs", arguments: nextSong);
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

  Future<void> _skipNext() async {
    final songsProvider = context.read<Songs>();

    switch (_playMode) {
      case PlayMode.repeatOne:
        // In repeat one mode, skip next should restart the current song
        _restartCurrentSong();
        break;
      case PlayMode.shuffle:
      case PlayMode.repeatAll:
        // Move to next song
        final nextSong = songsProvider.getNextSong();
        if (nextSong != null) {
          _playNextSong(nextSong);
        }
        break;
    }
  }

  Future<void> _skipPrevious() async {
    final songsProvider = context.read<Songs>();

    switch (_playMode) {
      case PlayMode.repeatOne:
        // In repeat one mode, skip previous should restart the current song
        _restartCurrentSong();
        break;
      case PlayMode.shuffle:
      case PlayMode.repeatAll:
        // Move to previous song
        final previousSong = songsProvider.getPreviousSong();
        if (previousSong != null) {
          _playNextSong(previousSong);
        }
        break;
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

  void _cyclePlayMode() {
    setState(() {
      switch (_playMode) {
        case PlayMode.shuffle:
          _playMode = PlayMode.repeatOne;
          break;
        case PlayMode.repeatOne:
          _playMode = PlayMode.repeatAll;
          break;
        case PlayMode.repeatAll:
          _playMode = PlayMode.shuffle;
          break;
      }
    });
    // Update the Songs provider with the new play mode
    context.read<Songs>().setPlayMode(_playMode);
    widget.onPlayModeChanged?.call(_playMode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_formatDuration(_currentPosition)),
            ),
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
              icon: Icon(
                _playMode == PlayMode.shuffle
                    ? Icons.shuffle_rounded
                    : _playMode == PlayMode.repeatOne
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
              ),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: _cyclePlayMode,
              iconSize: 32,
              tooltip: _playMode == PlayMode.shuffle
                  ? 'Shuffle'
                  : _playMode == PlayMode.repeatOne
                      ? 'Repeat one'
                      : 'Repeat all',
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: _skipPrevious,
              iconSize: 40,
              tooltip: 'Previous song',
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
              icon: const Icon(Icons.skip_next_rounded),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: _skipNext,
              iconSize: 40,
              tooltip: 'Next song',
            ),
            IconButton(
              icon: const Icon(Icons.stop_rounded),
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: () {
                _stop();
              },
              iconSize: 32,
              tooltip: 'Stop',
            ),
          ],
        ),
      ],
    );
  }
}
