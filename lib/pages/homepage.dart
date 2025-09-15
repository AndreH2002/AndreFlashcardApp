import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deckmodel.dart';
import '../services/database_service.dart';
import '../services/deck_provider.dart';
import 'createpage.dart';
import 'deckpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<DeckOperationStatus>? _deckFetchFuture;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _deckFetchFuture = context.read<DeckService>().getDeckList();
      }); // trigger rebuild once future is ready
    });
  }

  //this attempts to get the deck list
  Future<bool> fetchAttempt() async {
    DeckOperationStatus fetch = await context.read<DeckService>().getDeckList();
    if (fetch == DeckOperationStatus.success) {
      return true;
    } else {
      return false;
    }
  }

  //this attempts to remove the deck
  Future<bool> awaitAttempt(int deckId) async {
    DeckOperationStatus removalAttempt =
        await context.read<DeckService>().removeDeck(deckId);

    if (removalAttempt == DeckOperationStatus.success) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4f5fc),

      //title area
      appBar: AppBar(
        backgroundColor: const Color(0xFF3b038a),
        title: const Text(
          'Flashcard App',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      //body
      body: Column(
        children: [
          //creation button and header
          _buildCreateDeckButton(),
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 10),

          //this is where the actual decks are stored if any
          Expanded(
            child: _deckFetchFuture == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<DeckOperationStatus>(
                    future: _deckFetchFuture,
                    builder: (context, snapshot) {
                      debugPrint(
                          'FutureBuilder: state=${snapshot.connectionState}, hasData=${snapshot.hasData}, data=${snapshot.data}, hasError=${snapshot.hasError}');
                      //loading symbol if decks aren't pulled up yet
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                        //detected error
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                        //success
                      } else if (snapshot.data == DeckOperationStatus.success) {
                        final decks = context.watch<DeckService>().listOfDecks;
                        debugPrint(
                            'Decks in provider: ${context.read<DeckService>().listOfDecks.length}');
                        return decks.isEmpty
                            ? const Center(child: Text('No decks available'))
                            : _buildDeckList();
                        //some other sort of weird error
                      } else {
                        return const Center(
                            child: Text('Failed to load deck data'));
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  //when pressed the create deck button redirects to new CreatePage widget
  Widget _buildCreateDeckButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePage(
                deckModel: DeckModel(
                    deckname: "New Deck", listOfCards: [], numOfCards: 0),
                isAlreadyCreated: false,
              ),
            ),
          );
          if (mounted) {
            setState(() {
              _deckFetchFuture = context.read<DeckService>().getDeckList();
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New Deck'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          backgroundColor: const Color(0xFF7D5FFF),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  //Retrieves all decks from the database
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
                  final bool? confirmed = await _showDeleteConfirmation(
                      deck.deckname, index, deckService);
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

  Widget _buildDeckRow(DeckModel deck, String deckname, int numOfCards) {
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
          title: Text(deckname,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            '$numOfCards cards',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  //this handles the logic behind deleteing a deck which is used using the swipe feature
  Future<bool?> _showDeleteConfirmation(
      String deckName, int index, DeckService deckService) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Deck'),
          content:
              Text('Are you sure you want to delete the deck "$deckName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                DatabaseService.instance.getDeckId(deckName).then((deckId) {
                  awaitAttempt(deckId).then((success) {
                    if (!context.mounted) return;

                    if (success) {
                      deckService.getDeckList().then((_) {
                        if (!context.mounted) return;
                        setState(() {});
                        Navigator.of(context).pop(true);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete deck')),
                      );
                      Navigator.of(context).pop(false);
                    }
                  });
                });
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
