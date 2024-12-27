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

  Future<String> _addDeckAttempt(DeckModel model) async {
    return await context.read<DeckService>().addDeck(model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleString,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (titleString.isEmpty || listOfCards.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deck title or cards cannot be empty')),
                );
                return;
              }
              final modelToSubmit = DeckModel(
                deckname: titleString,
                listOfCards: listOfCards,
                numOfCards: listOfCards.length,
              );
              await _addDeckAttempt(modelToSubmit);
              if(mounted){
                Navigator.pop(context);
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) => setState(() => titleString = value),
            ),
          ),
          Expanded(
            child: listOfCards.isEmpty
                ? Center(child: Text('No cards added yet.'))
                : ListView.builder(
                    itemCount: listOfCards.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CreationCard(model: listOfCards[index]),
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() => listOfCards.add(CardModel())),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {
                  if (listOfCards.isNotEmpty) {
                    setState(() => listOfCards.removeLast());
                  }
                },
                icon: const Icon(Icons.remove_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
