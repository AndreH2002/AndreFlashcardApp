import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/models/cardmodel.dart';
import '../cards/creationcard.dart';
import '../models/deckmodel.dart';
import '../services/deckprovider.dart';


class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.listOfCards});
  final List<CardModel> listOfCards;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String titleString = "New Deck";
  late List<CardModel> listOfCards;

  @override
  void initState() {
    super.initState();
    listOfCards = List.from(widget.listOfCards);
  }

  //adds the deck through the try catch method definded in deckservice
  Future<bool> _addDeckAttempt(DeckModel model) async {
    String attempt = await context.read<DeckService>().addDeck(model);
    return attempt == "OK";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FC),
      appBar: AppBar(
        title: const Text(
          'Create Deck',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3B038A),
        actions: [
          TextButton(
            onPressed: () async {

              //checks for empty title or list
              if (titleString.isEmpty || listOfCards.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deck title or cards cannot be empty')),
                );
                return;
              }

              //checks for duplicate title string
              else if(await context.read<DeckService>().deckNameExists(titleString)) {
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar( 
                  const SnackBar(content: Text('Deck title already exists or failure to add deck')),
                );
                }
                return;
              }
              else {


              //tries to add deck from database
              _checkForNullTerms(listOfCards);
              final modelToSubmit = DeckModel(
                deckname: titleString,
                listOfCards: listOfCards,
                numOfCards: listOfCards.length,
              );
              if (await _addDeckAttempt(modelToSubmit) && context.mounted) {
                Navigator.pop(context);
              } else {
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to add deck')),
                );
                }
              }
              }
             
            },
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [

          //title field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Deck Title',
                labelStyle: const TextStyle(fontSize: 18, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (value) => setState(() => titleString = value),
            ),
          ),

          //builder of all the different creation cards

          Expanded(
            child: listOfCards.isEmpty
                ? const Center(
                    child: Text(
                      'No cards added yet.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: listOfCards.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) => listOfCards.removeAt(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CreationCard(model: listOfCards[index]),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),

          // bottom row

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              //add button
              ElevatedButton.icon(
                onPressed: () => setState(() => listOfCards.add(CardModel())),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D5FFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              //remove last button
              ElevatedButton.icon(
                onPressed: () {
                  if (listOfCards.isNotEmpty) {
                    setState(() => listOfCards.removeLast());
                  }
                },
                icon: const Icon(Icons.remove_circle, size: 20),
                label: const Text('Remove Last'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  //we need a function to remove any cards that don't have any text in the term or definition
  void _checkForNullTerms(List<CardModel>listToCheck) {
    listToCheck.removeWhere((element) => element.term == null || element.definition == null);
  }
}