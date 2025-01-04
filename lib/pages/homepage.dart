import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/deckprovider.dart';
import 'createpage.dart';
import 'deckpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

String dataFetchAttempt = "";

@override
void didChangeDependencies() {
  super.didChangeDependencies(); 
  fetchAttempt();
}

Future<void> fetchAttempt() async {
  dataFetchAttempt = await context.watch<DeckService>().getDeckList();
  setState(() {}); 
}

Future<bool> awaitAttempt(int deckId) async {
  String attempt = await context.read<DeckService>().removeDeck(deckId);
  if(attempt == "OK") {
    return true;
  } 
  else {
    return false;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Application'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePage(listOfCards: []),

                ),
              );
            },
            child: const Text('Create new deck'),
          ),
          
          Center(child: _buildHeader()),

          Expanded(
            child: 
            dataFetchAttempt == "OK"
            ? _buildDeckList()
            : Text('No data'),
          ),
        ],
      ),
    );
  }

  //combines all of the rows
  Widget _buildDeckList() {
  return Consumer<DeckService>(
    builder: (context, deckService, child) {
      return ListView.builder(
        itemCount: deckService.listOfDecks.length,
        itemBuilder: (context, index) {
          final deck = deckService.listOfDecks[index];
          
          return Dismissible(
            key: ValueKey(deck.deckname),
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            direction: DismissDirection.horizontal, 
            confirmDismiss: (direction) async {
              if(direction == DismissDirection.horizontal) {
                //get the pop up
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog (  
                      content: Text('Are you sure you want to delete this deck?'),
                      actions: <Widget> [
                        ElevatedButton(
                          child: Text('Delete'),
                          onPressed: () {
                            int deckId = DatabaseService.instance.getDeckId(deck.deckname) as int;
                            awaitAttempt(deckId) as bool
                            ? 
                              {
                                deckService.listOfDecks.removeAt(index),
                                Navigator.of(context).pop(true)
                              }
                            
                            : ScaffoldMessenger.of(context).showSnackBar(  
                                const SnackBar(content: Text('ERROR: Failed to remove')) );
                              Navigator.of(context).pop(false);
                          }
                        ),
                        ElevatedButton(  
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          }
                        )
                       
                      ]
                    );
                  }
                );
                 return confirmed ?? false;
              }
              return false;
            } 
            ,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckPage(deckModel: deck),
                  ),
                );
              },
              child: buildRow(
                deck.deckname,
                deck.numOfCards,
                index,
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildRow(String deckname, int numOfCards, int index){
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(deckname)),
          Expanded(
            flex: 1,
            child: Text(
              '$numOfCards',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[300],
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Deckname',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              'Number of Cards',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
