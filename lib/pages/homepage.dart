import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deckmodel.dart';
import '../providers/provider.dart';
import 'createpage.dart';
import '../models/cardmodel.dart';
import 'deckpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                  builder: (context) => CreatePage(listOfCards: [CardModel()]),
                ),
              );
            },
            child: const Text('Create new deck'),
          ),
          
          Center(child: _buildHeader()),
          Expanded(
            child: SingleChildScrollView(child: _formRows(context.watch<DeckProvider>().listOfDecks)),
          ),
        ],
      ),
    );
  }

  Widget _formRows(List<DeckModel> listOfDeckModels) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: listOfDeckModels.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(  
              context,
              MaterialPageRoute(builder: (context) => DeckPage(deckIndex: index),
              ),
            );
          },
          child: buildRow(
            listOfDeckModels[index].deckname,
            listOfDeckModels[index].numOfCards,
          ),
        );
      },
    );
  }

  Widget buildRow(String deckname, int numOfCards) {
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
