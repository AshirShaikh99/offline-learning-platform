import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// A service to manage audio playback throughout the app
class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentSound = '';

  /// Factory constructor to return the singleton instance
  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  /// Initialize the audio service
  Future<void> initialize() async {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
    });
  }

  /// Play a sound from an asset
  Future<void> playAsset(String assetPath) async {
    if (_isPlaying) {
      await _audioPlayer.stop();

      // If the same sound is played again, just stop it
      if (_currentSound == assetPath) {
        _isPlaying = false;
        _currentSound = '';
        return;
      }
    }

    _isPlaying = true;
    _currentSound = assetPath;

    try {
      await _audioPlayer.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
      );
    } catch (e) {
      debugPrint('Error playing sound: $e');
      _isPlaying = false;
    }
  }

  /// Stop any playing audio
  Future<void> stopAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSound = '';
    }
  }

  /// Dispose the audio player
  Future<void> dispose() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  }

  /// Check if audio is currently playing
  bool get isPlaying => _isPlaying;

  /// Get the currently playing sound path
  String get currentSound => _currentSound;
}
