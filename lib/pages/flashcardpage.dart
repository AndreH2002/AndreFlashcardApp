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
  List<CardModel>listOfCards = [];
  int currentCardIndex = 1;
  int totalCards = 0;

  @override
  void initState() {
    super.initState();
    listOfCards = widget.deckModel.listOfCards;
    totalCards = listOfCards.length;
    
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentCard = Flashcard(
      frontText: listOfCards[currentCardIndex].term!,
      backText: listOfCards[currentCardIndex].definition!,
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: null,
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreContainer(
                  color: Colors.red,
                  text: '0',
                  alignment: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                _buildScoreContainer(
                  color: const Color(0xFF12e35b),
                  text: '0',
                  alignment: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cardHeight = constraints.maxHeight * 0.8;
                final double cardWidth = constraints.maxWidth * 0.8;
                return Draggable( 
                feedback: SizedBox(
                  height: cardHeight,
                  width: cardWidth,
                  child: currentCard),
                  childWhenDragging: Container(),
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: currentCard
                  ),
                
                );
              }
              
            ),
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
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildScoreContainer({
    required Color color,
    required String text,
    required BorderRadius alignment,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 5),
        borderRadius: alignment,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      height: 60,
      width: 60,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}
