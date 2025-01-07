// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class FinalTimeDisplay extends StatefulWidget {
  FinalTimeDisplay({super.key, required this.time, required this.playAgainButtonPressed, required this.goBackButtonPressed});
  String time;
  VoidCallback playAgainButtonPressed;
  VoidCallback goBackButtonPressed;

  @override
  State<FinalTimeDisplay> createState() => _FinalTimeDisplayState();
}

class _FinalTimeDisplayState extends State<FinalTimeDisplay> {
  //build a list of the top 10 times 
  late List<int>topTen;
  //

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          Text('Your time was ${widget.time} seconds'),
          Row(
            children: [
              TextButton(onPressed: widget.playAgainButtonPressed, child: Text('Play again')),
              TextButton(onPressed: widget.goBackButtonPressed, child: Text('Go Back')),
            ],
          ),
        ],
      ),
    );
  }
}