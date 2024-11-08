// widgets/voice_note/audio_player_widget.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final int duration;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.duration,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      _audioPlayer.positionStream.listen((position) {
        setState(() => _position = position);
      });

      _audioPlayer.playerStateStream.listen((playerState) {
        setState(() {
          _isPlaying = playerState.playing;
        });
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.play();
              }
            },
          ),
          Slider(
            value: _position.inSeconds.toDouble(),
            max: widget.duration.toDouble(),
            onChanged: (value) {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            },
          ),
          Text(
            '${_position.inSeconds}/${widget.duration}s',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
