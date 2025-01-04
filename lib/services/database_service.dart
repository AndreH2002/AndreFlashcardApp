import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cardmodel.dart';
import '../models/deckmodel.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;
  DatabaseService._constructor();

  final String decksTable = "decks";
  final String listTable = "lists";

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
        _onCreate(db, version);
      },
      onConfigure: _onConfigure,
    );
    return database;
  }

  Future<void> deleteOldDatabase() async {
    final databasePath = join(await getDatabasesPath(), "master_db.db");
    await deleteDatabase(databasePath);
  }

  Future _onCreate(Database db, int version) async {
    db.execute('''
        CREATE TABLE $decksTable (
          ${DeckFields.deckID} INTEGER PRIMARY KEY,
          ${DeckFields.deckname} TEXT NOT NULL,
          ${DeckFields.numOfCards} INTEGER NOT NULL
        )
        ''');

        db.execute('''
        CREATE TABLE $listTable (
          ${CardFields.listID} INTEGER PRIMARY KEY,
          ${CardFields.listDeckID} INTEGER NOT NULL,
          ${CardFields.term} TEXT NOT NULL,
          ${CardFields.definition} TEXT NOT NULL,
          FOREIGN KEY (${CardFields.listDeckID}) REFERENCES $decksTable (${DeckFields.deckID})
        )
        ''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> addDeck(DeckModel deck) async {
    final db = await instance.database;
    final deckId = await db.rawInsert(
      'INSERT INTO $decksTable(${DeckFields.deckname}, ${DeckFields.numOfCards}) VALUES(?, ?)', 
      [deck.deckname, deck.numOfCards]
    );

    for(final card in deck.listOfCards) {
      await db.rawInsert( 
        'INSERT INTO $listTable(${CardFields.listDeckID}, ${CardFields.term}, ${CardFields.definition}) VALUES(?, ?, ?)',
        [deckId, card.term, card.definition],
      );
    }
  }

  Future<int> removeDeck(int deckId) async {
    final db = await instance.database;
    await db.rawDelete('DELETE FROM $listTable WHERE ${CardFields.listDeckID} = ?', [deckId]);
    return db.rawDelete('DELETE FROM $decksTable WHERE ${DeckFields.deckID} = ?', [deckId]);
  }

  Future<int>getDeckId(String name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM $decksTable WHERE ${DeckFields.deckname} = ?', [name]
    );
    if(result.isNotEmpty) {
      return result.first[DeckFields.deckID] as int;
    } 
    else {
      return -1;
    }
  }

  Future<List<DeckModel>> getDecks() async {
    final db = await instance.database;

    final data = await db.query(decksTable);
    List<DeckModel> decks = [];
    for (final e in data) {
      final cards = await getCards(e[DeckFields.deckID] as int); 
      decks.add(DeckModel(
        deckname: e[DeckFields.deckname] as String,
        listOfCards: cards,
        numOfCards: e[DeckFields.numOfCards] as int,
      ));
    }
    return decks;
  }

  Future<DeckModel> getDeckModelFromID(int id) async {
    final db = await instance.database;
    final deckRow = await db.rawQuery(  
      'SELECT * FROM $decksTable WHERE ${DeckFields.deckID} = ?',
      [id]
    );

    final deckList = await getCards(deckRow.first[DeckFields.deckID] as int);
    
    DeckModel modelToReturn = DeckModel(deckname: deckRow.first[DeckFields.deckname] as String, listOfCards: deckList, 
      numOfCards: deckRow.first[DeckFields.numOfCards] as int);

    return modelToReturn;
  }

  Future<DeckModel> getDeckModelFromName(String deckname) async {
    final db = await instance.database;
    final deckRow = await db.rawQuery(  
      'SELECT * FROM $decksTable WHERE ${DeckFields.deckname} = ?', [deckname]
    );

    final deckList = await getCards(deckRow.first[DeckFields.deckID] as int);
    DeckModel modelToReturn = DeckModel(deckname: deckname, listOfCards: deckList, numOfCards: deckRow.first[DeckFields.numOfCards] as int);
    return modelToReturn;
  }

  Future<List<CardModel>> getCards(int deckID) async {
    final db = await instance.database;
    final result = await db.rawQuery( 
      'SELECT * FROM $listTable WHERE ${CardFields.listDeckID} = ?', 
      [deckID]
    );
  return result.map((e) => CardModel( 
    term: e[CardFields.term] as String,
    definition: e[CardFields.definition] as String,
  )).toList();
 } 

 Future<bool> deckNameExists(String name) async {
  final db = await instance.database;
  final result = await db.rawQuery(  
    'SELECT * FROM $decksTable WHERE ${DeckFields.deckname} = ?',
    [name]
  );
  if(result.isNotEmpty) {
    return true;
  }
  else {
    return false;
  }
 }

}
