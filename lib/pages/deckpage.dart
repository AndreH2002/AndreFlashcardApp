import 'package:flutter/material.dart';
import 'package:revised_flashcard_application/pages/createpage.dart';
import '../cards/flashcard.dart';
import '../models/cardmodel.dart';
import '../models/deckmodel.dart';
import 'flashcardpage.dart';
import 'learnpage.dart';
import 'matchpage.dart';

class DeckPage extends StatefulWidget {
  final DeckModel deckModel;
  const DeckPage({super.key, required this.deckModel});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  late DeckModel deckModel;
  late List<CardModel> listOfCards;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    deckModel = widget.deckModel;
    listOfCards = deckModel.listOfCards;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3b038a),
        title: Text(
          deckModel.deckname,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //TODO: add download logic
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollview for the flashcards horitzontal
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: listOfCards.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 225,
                      child: Flashcard(
                        frontText: listOfCards[index].term,
                        backText: listOfCards[index].definition,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),


          // Deck Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      deckModel.deckname,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    IconButton(onPressed: _goToCreatePage, icon: Icon(Icons.edit)),
                  ],
                ),
                Text(
                  '${listOfCards.length} Terms',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Navigation Options Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  _buildNavigationOption(
                    
                    label: 'Flashcards',
                    onTap: () {
                      if(listOfCards.isNotEmpty) {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardPage(deckModel: deckModel),
                        ),
                      );
                      }
                      
                    },
                  ),
                  _buildNavigationOption(
                    label: 'Learn',
                    onTap: () {
                      if(listOfCards.isNotEmpty && listOfCards.length > 4) {
                         Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearnPage(deckModel: deckModel),
                        ),
                      );
                      }
                     
                    },
                  ),
                  _buildNavigationOption(
                    label: 'Test',
                    onTap: () {
                      //TODO: Add Test Page Navigation
                    },
                  ),
                  _buildNavigationOption(
                    label: 'Match',
                    onTap: () {
                      if(listOfCards.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchPage(deckModel: deckModel),
                        ),
                      );
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error, list is empty'),),
                        );

                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationOption({required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF7D5FFF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  void _goToCreatePage() {
    Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePage(deckModel: widget.deckModel, isAlreadyCreated: true,),
            ),
          );
  }
}