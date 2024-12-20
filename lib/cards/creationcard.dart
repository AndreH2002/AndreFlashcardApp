import 'package:flutter/material.dart';
import '../models/cardmodel.dart';

class CreationCard extends StatefulWidget {
  const CreationCard({super.key, required this.model});

  final CardModel model;

  @override
  State<CreationCard> createState() => _CreationCardState();
}

class _CreationCardState extends State<CreationCard> {
  late TextEditingController termController;
  late TextEditingController defController;

  @override
  void initState() {
    super.initState();
    termController = TextEditingController(text: widget.model.term)
      ..addListener(() {
        setState(() {
          widget.model.term = termController.text;
        });
      });
    defController = TextEditingController(text: widget.model.definition)
      ..addListener(() {
        setState(() {
          widget.model.definition = defController.text;
        });
      });
  }

  @override
  void dispose() {
    termController.dispose();
    defController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Term
        TextField(
          decoration: const InputDecoration(label: Text('Term')),
          controller: termController,
        ),

        //Definition
        TextField(
          decoration: const InputDecoration(label: Text('Definition')),
          controller: defController,
        ),
      ],
    );
  }
}
