import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/models/cardmodel.dart';
import '../cards/creationcard.dart';
import '../models/deckmodel.dart';
import '../services/deckprovider.dart';


class CreatePage extends StatefulWidget {
 const CreatePage({super.key, required this.deckModel, required this.isAlreadyCreated});
  final DeckModel deckModel;
  final bool isAlreadyCreated;
  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  late String titleString;
  late List<CardModel> listOfCards;
  late DeckModel model;
  @override
  void initState() {
    super.initState();
    titleString = widget.deckModel.deckname;
    listOfCards = widget.deckModel.listOfCards;
    model = widget.deckModel;
  }

  //adds the deck through the try catch method definded in deckservice
  Future<bool> _addDeckAttempt() async {
    final (status, result) = await context.read<DeckService>().addDeck(model);
    if (status == DeckOperationStatus.success && result != null) {
      debugPrint(result.deckID.toString());
      setState(() {
      model = result;
      });
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> _updateDeckAttempt() async {
    DeckOperationStatus result = await context.read<DeckService>().updateDeck(model);
    if(result == DeckOperationStatus.success) {
      return true;
    }
    else {
      return false;
    }
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
            // 1. Check for empty title or empty card list
          if (titleString.isEmpty || listOfCards.isEmpty) {
          if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deck title or cards cannot be empty')),
          );
          return;
          }

        // 2. Check for duplicate title
        final exists = await context.read<DeckService>().deckNameExists(titleString);
    if (exists == true && titleString != widget.deckModel.deckname) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deck title already exists')),
    );
    return;
  }

  // 3. Clean up card list (remove null terms etc.)
  _checkForNullTerms(listOfCards);

  //4. update DeckModel with the title and num of cards
  model.deckname = titleString;
  model.listOfCards = listOfCards;
  model.numOfCards = listOfCards.length;

  // 5. Attempt to add deck 

  if(widget.isAlreadyCreated) {
    final success = await _updateDeckAttempt();
      if(!context.mounted) return;

      if(success) {
        if(context.mounted) {
          Navigator.pop(context);
        }
        
      }
      else {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(  
          const SnackBar(content: Text('Failed to update deck')),
        );
        }
        
      }
  }
  else{
    final success = await _addDeckAttempt();
    debugPrint('After adding deck, model.deckID = ${model.deckID}');
      if (!context.mounted) return;

      if (success) {
        if(context.mounted) {
          Navigator.pop(context);
        }
      }
      else {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add deck')));
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
                onPressed: () => setState(() => listOfCards.add(CardModel(term: "", definition: ""))),
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
    listToCheck.removeWhere((element) => element.term == "" || element.definition == "");
  }
}