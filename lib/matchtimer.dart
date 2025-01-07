import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/timerprovider.dart';

class MatchTimer extends StatefulWidget {
  const MatchTimer({super.key});

  @override
  State<MatchTimer> createState() => _MatchTimerState();
}

class _MatchTimerState extends State<MatchTimer> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 100),
    (Timer timer) {
      setState(() {
        context.read<TimerProvider>().updateTime();
      });
    });

    
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
  
  @override
  Widget build(BuildContext context) {
    return formatTime(context.watch<TimerProvider>().duration);
  }

  Widget formatTime(Duration duration) {
    String seconds = duration.inSeconds.toString();
    String milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 100).toString();

    return Text('$seconds.$milliseconds');
  }
}

