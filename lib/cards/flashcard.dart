import 'dart:math';

import 'package:flutter/material.dart';

class Flashcard extends StatefulWidget {
  const Flashcard({super.key, required this.frontText, required this.backText, this.frontImagePath, this.backImagePath});

  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isFront = !_isFront; 
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _runAnimation,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          return 
          _isFront
            ?_buildTransform(true)
            :_buildTransform(false);
        },
      ),
    );
  }

  //function takes in a bool thats true if term and false if definition
  //creates the card flip animation
  Widget _buildTransform(bool isFront){
    String frontText;
    String backText;
    // ignore: unused_local_variable
    String? frontImagePath;
    // ignore: unused_local_variable
    String? backImagePath;

    if(isFront) {
      frontText = widget.frontText;
      backText = widget.backText;
      frontImagePath = widget.frontImagePath;
      backImagePath = widget.backImagePath;
     
      
    }
    else {
      frontText = widget.backText;
      backText = widget.frontText;
      frontImagePath = widget.backImagePath;
      backImagePath = widget.frontImagePath;
    }
    return Transform(  
        alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(_flipAnimation.value),
              child: _flipAnimation.value <= pi / 2
                  ? _buildCard(
                    frontText,
                    frontImagePath
                    )
                  : Transform(
                     alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildCard(backText, backImagePath),
                    ),
    );
  }


  //creates the card within the transformation
  Widget _buildCard(String text, String? imagePath) {
    return Container(
      decoration: BoxDecoration( 
        gradient: const LinearGradient(
                    colors: [Color(0xFF7D5FFF), Color(0xFFB17FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
            child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
      ),
      
    );
  }

  //runs the animation
  void _runAnimation() {
    if (_controller.isAnimating) return;
    _controller.forward();
  }
}
