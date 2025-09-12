import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  Timer? timer;
  Stopwatch stopwatch = Stopwatch();
  Duration duration = Duration.zero;

  void startTime() {
    timer?.cancel;
    stopwatch.stop();

    stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      duration = stopwatch.elapsed;
    });

    notifyListeners();
  }

  void stopTime() {
    stopwatch.stop();
    timer?.cancel();
    notifyListeners();
  }

  void resetTime() {
    stopwatch.stop();
    timer?.cancel();
    stopwatch.reset();
    duration = Duration.zero;
    notifyListeners();
  }

  void updateTime() {
    duration = stopwatch.elapsed;
    notifyListeners();
  }
}
