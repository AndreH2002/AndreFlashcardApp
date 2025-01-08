import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deckmodel.dart';
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
    return attempt == "OK";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4f5fc),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3b038a),
        title: const Text(
          'Flashcard App',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCreateDeckButton(),
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: dataFetchAttempt == "OK"
                ? _buildDeckList()
                : const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.black54, fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateDeckButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePage(listOfCards: []),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New Deck'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          backgroundColor: const Color(0xFF7D5FFF),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

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
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.startToEnd,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  final bool? confirmed = await _showDeleteConfirmation(deck.deckname, index, deckService);
                  return confirmed ?? false;
                }
                return false;
              },
              child: _buildDeckRow(deck, deck.deckname, deck.numOfCards),
            );
          },
        );
      },
    );
  }

  Widget _buildDeckRow(DeckModel deck,String deckname, int numOfCards) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeckPage(deckModel: deck),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: ListTile(
          title: Text(deckname, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            '$numOfCards cards',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(String deckName, int index, DeckService deckService) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Deck'),
          content: Text('Are you sure you want to delete the deck "$deckName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final deckId = await DatabaseService.instance.getDeckId(deckName);
                final success = await awaitAttempt(deckId);
                if (success && context.mounted) {
                  deckService.listOfDecks.removeAt(index);
                  Navigator.of(context).pop(true);
                } else {
                  if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete deck')),
                  );
                  }
                  if(context.mounted) {
                    Navigator.of(context).pop(false);
                  }
                  
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFe0e0e0),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Deck Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Cards',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
