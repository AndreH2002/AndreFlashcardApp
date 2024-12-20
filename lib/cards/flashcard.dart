import 'package:flutter/material.dart';

class Flashcard extends StatefulWidget {
  const Flashcard({super.key, required this.frontText, required this.backText});
  final String frontText;
  final String backText;
  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() => _switchCard(),
      child: Card( 
        color: Colors.blue[700],
        child: 
          Center(child: Text(widget.frontText),)
      ),
    );
  }
}

Widget _buildFront(){
  return Placeholder();
}

Widget _buildBack() {
  return Placeholder();
}

void _switchCard() {

}