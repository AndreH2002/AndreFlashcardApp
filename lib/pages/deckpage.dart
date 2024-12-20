import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cards/flashcard.dart';
import '../models/cardmodel.dart';
import '../models/deckmodel.dart';
import '../providers/provider.dart';

class DeckPage extends StatefulWidget {
  final int deckIndex;
  const DeckPage({super.key, required this.deckIndex});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  late DeckModel deckModel;
  late List<CardModel>listOfCards;

  @override
  void initState() {
    
    super.initState();
  }

  @override
  void didChangeDependencies() {
    deckModel = context.watch<DeckProvider>().listOfDecks.elementAt(widget.deckIndex);
    listOfCards = deckModel.listOfCards;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(  
        
      ),
      body: Column(  
        children: [  
          Container(
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
                    child: Container(width: 250, color: Colors.blue[700], child: 
                      Flashcard(frontText: '${listOfCards.elementAt(index).term}', 
                                  backText: '${listOfCards.elementAt(index).definition}')),
                  );
              },),
            ),
          ),
          

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(deckModel.deckname, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
                      const IconButton(onPressed: null, icon: Icon(Icons.download)),
                    ],
                  ),
                  Text('${listOfCards.length} Terms', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(  
              height: 200,
              child: ListView(  
                children: [ 
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700],child: const Text('Flashcards', textScaleFactor: 2.0))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700],child: const Text('Learn', textScaleFactor: 2.0))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700],child: const Text('Test', textScaleFactor: 2.0))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700], child: const Text('Match', textScaleFactor: 2.0))),
                  ),
              ],
            ),
            ),
          ),


        ],
      ),
    );
  }
}