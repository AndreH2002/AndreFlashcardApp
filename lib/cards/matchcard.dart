// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class MatchCard extends StatefulWidget {
  MatchCard({super.key, required this.text, this.partner, this.imagePath});
  MatchCard? partner;
  final String text;
  final String? imagePath;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  late String text;

  @override
  void initState() {
    super.initState();
    text = widget.text;
  }
  @override
  Widget build(BuildContext context) {
    
    return Text(text);
  }
}

