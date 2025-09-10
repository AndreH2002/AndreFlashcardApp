import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class TtsProvider extends ChangeNotifier {
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;

  TtsState get ttsState => _ttsState;

  Future<void> initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });
  }

  Future<void> speak(String text,
      {double volume = 1.0, double pitch = 1.0, double rate = 0.5}) async {
    await _flutterTts.setVolume(volume);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _ttsState = TtsState.stopped;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
