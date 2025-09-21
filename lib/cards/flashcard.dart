import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/services/tts_provider.dart';

class Flashcard extends StatefulWidget {
  const Flashcard({
    super.key,
    required this.frontText,
    required this.backText,
    this.frontImageFileName,
    this.backImageFileName,
  });

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
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.0, // start at front
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runAnimation() {
    if (_controller.isAnimating) return;

    if (isFront) {
      _controller.forward().whenComplete(() {
        setState(() => isFront = false);
      });
    } else {
      _controller.reverse().whenComplete(() {
        setState(() => isFront = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _runAnimation,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value;
          final isShowingFront = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isShowingFront
                ? _buildCard(widget.frontText, widget.frontImageFileName)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child:
                        _buildCard(widget.backText, widget.backImageFileName),
                  ),
          );
        },
      ),
    );
  }

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filename != null) ...[
                        FutureBuilder<File?>(
                          future: _getImageFile(filename),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Icon(Icons.broken_image,
                                  size: 60, color: Colors.white);
                            }
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight * 0.5,
                                maxWidth: constraints.maxWidth,
                              ),
                              child: Image.file(
                                snapshot.data!,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: constraints.maxWidth * 0.08,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Consumer<TtsProvider>(
                builder: (context, ttsProvider, _) => IconButton(
                  onPressed: () => ttsProvider.speak(text),
                  icon: const Icon(Icons.volume_up),
                  iconSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> _getImageFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists() ? file : null;
  }
}
