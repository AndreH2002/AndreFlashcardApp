import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/services/tts_provider.dart';

class Flashcard extends StatefulWidget {
  const Flashcard(
      {super.key,
      required this.frontText,
      required this.backText,
      this.frontImageFileName,
      this.backImageFileName});

  final String frontText;
  final String backText;
  final String? frontImageFileName;
  final String? backImageFileName;

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard>
    with SingleTickerProviderStateMixin {
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
          return _isFront ? _buildTransform(true) : _buildTransform(false);
        },
      ),
    );
  }

  //function takes in a bool thats true if term and false if definition
  //creates the card flip animation
  Widget _buildTransform(bool isFront) {
    String frontText = isFront ? widget.frontText : widget.backText;
    String backText = isFront ? widget.backText : widget.frontText;
    String? frontImagePath = isFront ? widget.frontImageFileName: widget.backImageFileName;
    String? backImagePath = isFront ? widget.backImageFileName: widget.frontImageFileName;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_flipAnimation.value),
      child: _flipAnimation.value <= pi / 2
          ? _buildCard(frontText, frontImagePath)
          : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi),
              child: _buildCard(backText, backImagePath),
            ),
    );
  }

  //creates the card within the transformation
  Widget _buildCard(String text, String? filename) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7D5FFF), Color(0xFFB17FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (filename != null) ...[
                    FutureBuilder(
                      future: _getImageFile(filename),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if(!snapshot.hasData || snapshot.data == null) {
                          return const Icon(Icons.broken_image, size: 40, color: Colors.white);
                        }
                        return Expanded(
                          child: Image.file(
                            snapshot.data!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image,
                                  size: 48, color: Colors.white);
                            },
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Sound icon in bottom-right
            Positioned(
              bottom: 8,
              right: 8,
              child: Consumer<TtsProvider>(
                builder: (context, ttsProvider, _) => IconButton(
                  onPressed: () {
                    //tts implementation here 
                    ttsProvider.speak(text);
                  },
                icon: const Icon(Icons.volume_up),
                iconSize: 28,
                color: Colors.white,
              ),
            ),
            )
          ],
        ),
      ),
    );
  }

  //runs the animation
  void _runAnimation() {
    if (_controller.isAnimating) return;
    _controller.forward();
  }

  Future<File?> _getImageFile(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  return await file.exists() ? file : null;
}
}
