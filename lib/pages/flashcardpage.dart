import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:revised_flashcard_application/cards/flashcard.dart';

import '../models/cardmodel.dart';
import '../models/deckmodel.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key, required this.deckModel});
  final DeckModel deckModel;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late Flashcard currentCard;
  List<CardModel> listOfCards = [];
  List<CardModel> stillLearning = []; // Left-swiped cards for future rounds

  final flashcardQueue = Queue<Flashcard>();
  int currentCardIndex = 0;
  int totalCards = 0;

  // Stats counts
  int needStudyingCount = 0;
  int masteredCount = 0;

  // State control for round completion
  bool roundFinished = false;
  
  //once its false the still learning button doesnt appear again
  bool learning = true;

  @override
  void initState() {
    super.initState();
    listOfCards = List.from(widget.deckModel.listOfCards);
    stillLearning = List.from(widget.deckModel.listOfCards);
    totalCards = listOfCards.length;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentCard = Flashcard(
      frontText: listOfCards[currentCardIndex].term,
      backText: listOfCards[currentCardIndex].definition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3b038a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3b038a),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentCardIndex/$totalCards',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: null,
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreContainer(
                color: Colors.red,
                text: '$needStudyingCount',
              ),
              _buildScoreContainer(
                color: const Color(0xFF12e35b),
                text: '$masteredCount',
              ),
            ],
          ),
          const SizedBox(height: 16),
      
          // Flashcard or finished widget
          Expanded(
            child: roundFinished
                ? finishedContainer()
                : _buildFlashcardView(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF3b038a),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {}, // Go back action
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              IconButton(
                onPressed: () {}, // Play action
                icon: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardView() {
    return Stack(
      children: [
        Positioned.fill(
          child: Align(alignment: Alignment.centerLeft, child: dragTarget(true)),
        ),
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardHeight = constraints.maxHeight * 0.7;
              final cardWidth = constraints.maxWidth * 0.9;
              return LongPressDraggable(
                data: currentCard,
                feedback: SizedBox(
                  height: cardHeight,
                  width: cardWidth,
                  child: currentCard,
                ),
                childWhenDragging: Container(),
                child: SizedBox(
                  height: cardHeight,
                  width: cardWidth,
                  child: currentCard,
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Align(alignment: Alignment.centerRight, child: dragTarget(false)),
        ),
      ],
    );
  }

  Widget dragTarget(bool left) {
    return DragTarget<Flashcard>(
      builder: (context, data, rejectedData) {
        return SizedBox(
          height: double.infinity,
          width: 100,
        );
      },
      onAcceptWithDetails: (data) {
        setState(() {
          left ? _needsStudying() : _mastered();
        });
      },
    );
  }

  void _needsStudying() {
   
  if (currentCardIndex < stillLearning.length - 1) {
    currentCardIndex++;
    needStudyingCount++;
    
    currentCard = Flashcard(
      frontText: stillLearning[currentCardIndex].term,
      backText: stillLearning[currentCardIndex].definition,
    );
  } else {
    needStudyingCount++;
    roundFinished = true;
  }

  }

  void _mastered() {
   
  if (currentCardIndex < stillLearning.length - 1) {
    masteredCount++;
    stillLearning.removeAt(currentCardIndex);
    currentCard = Flashcard(
      frontText: stillLearning[currentCardIndex].term,
      backText: stillLearning[currentCardIndex].definition,
    );
  } else {
    masteredCount++;
    stillLearning.removeAt(currentCardIndex);
    if(stillLearning.isEmpty) {
      learning = false;
    }
    roundFinished = true;
  }
  }

  Widget finishedContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stats Section
        Text(
          'Still Learning: $needStudyingCount',
          style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Mastered: $masteredCount',
          style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Chart Section
        chart(masteredCount, totalCards),

        const SizedBox(height: 24),

        //Button Section
        Visibility(
          visible: learning,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentCardIndex = 0;
                needStudyingCount = 0;
                masteredCount = 0;
                totalCards = stillLearning.length;
                roundFinished = false;
          
                currentCard = Flashcard(
                  frontText: stillLearning[currentCardIndex].term,
                 backText: stillLearning[currentCardIndex].definition);
          
                
              });
            }, 
            child: const Text('Continue Studying'),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {

            //clear the list and reset it to the listOfCards
            setState(() {

              needStudyingCount = 0;
              masteredCount = 0;

              
              totalCards = listOfCards.length;
              stillLearning = List.from(listOfCards);

              //reset the index and current card to the first in the list
              currentCardIndex = 0;
              currentCard = Flashcard(
                frontText: stillLearning[currentCardIndex].term,
               backText: stillLearning[currentCardIndex].definition);
              
              learning = true;


              //go back to flashcard screen
              roundFinished = false;
            });
          }, 
          child: const Text('Restart Flashcards'),
        ),
      ],
    );
  }

  Widget _buildScoreContainer({
    required Color color,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 50,
      width: 80,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget chart(int mastered, int totalTerms) {
    double masteredPercentage = mastered / totalTerms;
    String toText = '${(masteredPercentage * 100).toStringAsFixed(2)}%';

    return Stack(
      alignment: Alignment.center,
        children: [
        CustomPaint(
          size: const Size(100, 100),
          painter: CircularChartPainter(masteredPercentage: masteredPercentage),
        ),

        Text(toText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
      ],
    );
  }
}

class CircularChartPainter extends CustomPainter {
  final double masteredPercentage;

  CircularChartPainter({required this.masteredPercentage});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 10;
    final double radius = (size.width / 2) - strokeWidth / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final masteredPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final learningPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final masteredAngle = 2 * pi * masteredPercentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      masteredAngle,
      false,
      masteredPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + masteredAngle,
      2 * pi - masteredAngle,
      false,
      learningPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
