import 'package:flutter/material.dart';
import '../cards/flashcard.dart';
import '../models/cardmodel.dart';
import '../models/deckmodel.dart';
import 'matchpage.dart';

class DeckPage extends StatefulWidget {
  final DeckModel deckModel;
  const DeckPage({super.key, required this.deckModel});

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
    deckModel = widget.deckModel;
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
                      child: Flashcard(frontText: '${listOfCards.elementAt(index).term}', 
                                  backText: '${listOfCards.elementAt(index).definition}'),
                    ),
                  );
              },),
            ),
          ),
          

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
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
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(  
              height: 200,
              child: ListView(  
                children: [ 
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700],child: const Text('Flashcards', textScaler: TextScaler.linear(2.0)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700],child: const Text('Learn', textScaler: TextScaler.linear(2.0)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.blue[700],child: const Text('Test', textScaler: TextScaler.linear(2.0)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap:() {
                          Navigator.push(context, MaterialPageRoute(builder:(context) => MatchPage()));
                        },
                        child: Container(color: Colors.blue[700], child: const Text('Match', textScaler: TextScaler.linear(2.0)))
                        )
                      ),
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