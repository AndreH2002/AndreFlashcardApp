import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cardmodel.dart';
import '../models/deckmodel.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String decksTable = "decks";
  final String listTable = "lists";

  final String _decksId = "id";
  final String _decksDeckname = "deckname";
  final String _decksNumOfCards = "numOfCards";

  final String _listId = "id";
  final String _listDeckId = "deckId"; // Foreign key to decks table
  final String _listTerm = "term";
  final String _listDefinition = "definition";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
      return _db!;
    }
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $decksTable (
          $_decksId INTEGER PRIMARY KEY,
          $_decksDeckname TEXT NOT NULL,
          $_decksNumOfCards INTEGER NOT NULL
        )
        ''');

        db.execute('''
        CREATE TABLE $listTable (
          $_listId INTEGER PRIMARY KEY,
          $_listDeckId INTEGER NOT NULL,
          $_listTerm TEXT NOT NULL UNIQUE,
          $_listDefinition TEXT NOT NULL,
          FOREIGN KEY ($_listDeckId) REFERENCES $decksTable ($_decksId)
        )
        ''');
      },
    );
    return database;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> addDeck(DeckModel deck) async {
    final db = await instance.database;
    final deckId = await db.insert(decksTable, {
      _decksDeckname: deck.deckname,
      _decksNumOfCards: deck.numOfCards,
    });

    for (final card in deck.listOfCards) {
      await db.insert(listTable, {
        _listDeckId: deckId,
        _listTerm: card.term,
        _listDefinition: card.definition,
      });
    }
  }


  Future<List<DeckModel>> getDecks() async {
    final db = await instance.database;

    final data = await db.query(decksTable);
    List<DeckModel> decks = [];
    for (final e in data) {
      final cards = await getCards(e[_decksId] as int); 
      decks.add(DeckModel(
        deckname: e[_decksDeckname] as String,
        listOfCards: cards,
        numOfCards: e[_decksNumOfCards] as int,
      ));
    }
    return decks;
  }

  Future<List<CardModel>> getCards(int deckID) async {
    final db = await instance.database;
    final result = await db.query(
      listTable,
      where: '$_listDeckId = ?',
      whereArgs: [deckID],
    );
    return result.map((e) => CardModel(
          term: e[_listTerm] as String,
          definition: e[_listDefinition] as String,
        )).toList();
  }
}
