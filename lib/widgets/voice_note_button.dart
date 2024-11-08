
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'waveform_painter.dart';

class VoiceNoteButton extends StatefulWidget {
  final Function(String path, int duration) onRecordingComplete;

  const VoiceNoteButton({
    super.key, 
    required this.onRecordingComplete,
  });

  @override
  State<VoiceNoteButton> createState() => _VoiceNoteButtonState();
}

class _VoiceNoteButtonState extends State<VoiceNoteButton> 
    with SingleTickerProviderStateMixin {
  final _audioRecorder = AudioRecorder(); 
  bool _isRecording = false;
  Timer? _timer;
  Timer? _amplitudeTimer;
  int _recordDuration = 0;
  late AnimationController _animationController;
  String? _recordingPath;
  final List<double> _waveformData = [];
  bool _isCancelled = false;
  double? _initialY;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  Future<void> _updateWaveform() async {
  try {
    // Assuming getAmplitude() returns an object with a 'current' property that holds the amplitude value
    final amplitudeResult = await _audioRecorder.getAmplitude(); // Adjust based on actual method
    final amplitude = amplitudeResult.current; // Extract the amplitude value

    // Normalize amplitude between 0 and 1
    // The amplitude usually ranges from -160 to 0 dB
    final double normalized;
    normalized = ((amplitude + 160) / 160).clamp(0.0, 1.0);
  // Default to 0 if amplitude is null

    setState(() {
      // Add the normalized amplitude to the waveform data
      _waveformData.add(normalized);
      // Keep the waveform data length manageable
      if (_waveformData.length > 50) {
        _waveformData.removeAt(0);
      }
    });
  } catch (e) {
    // Improved error handling
    print('Error updating waveform: $e');
  }
}

  Future<void> _start() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Check if recording is already initialized
        if (!await _audioRecorder.isRecording()) {
          // Configure recording
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              bitRate: 128000,
            ),
            path: _recordingPath!,
          );

          setState(() {
            _isRecording = true;
            _waveformData.clear();
          });

          // Start duration timer
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _recordDuration++;
            });
          });

          // Start amplitude timer
          _amplitudeTimer = Timer.periodic(
            const Duration(milliseconds: 50),
            (_) => _updateWaveform(),
          );
        }
      } else {
        print('Microphone permission denied');
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stop() async {
    try {
      await _audioRecorder.stop();
      _timer?.cancel();
      _amplitudeTimer?.cancel();
      setState(() {
        _isRecording = false;
      });
      if (_recordingPath != null && !_isCancelled) {
        widget.onRecordingComplete(_recordingPath!, _recordDuration);
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _cancel() async {
    setState(() => _isCancelled = true);
    await _stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
    _audioRecorder.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (_initialY != null && details.localPosition.dy < _initialY!) {
          _cancel();
        }
      },
      onPanStart: (details) {
        _initialY = details.localPosition.dy;
      },
      onTapDown: (_) {
        if (!_isRecording) {
          _start();
        }
      },
      onTapUp: (_) {
        if (_isRecording) {
          _stop();
        }
      },
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(50, 50),
            painter: WaveformPainter(
              waveformData: _waveformData,
              color: Colors.blue,
              isRecording: _isRecording,
            ),
          ),
          Icon(
            _isRecording ? Icons.stop : Icons.mic,
            size: 50,
            color: _isRecording ? Colors.red : Colors.blue,
          ),
        ],
      ),
    );
  }
}