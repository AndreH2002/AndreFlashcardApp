import 'package:flutter/material.dart';

import '../models/deckmodel.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key, required this.deckModel});
  final DeckModel deckModel;

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(  

    );
  }
}