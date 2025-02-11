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
    } 
    
    else {
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
          FOREIGN KEY (${CardFields.listDeckID}) REFERENCES $decksTable (${DeckFields.deckID}) ON DELETE CASCADE
        )
        ''');

        
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    
  }

  Future<bool> columnExists(Database db, String table, String column) async {
  final result = await db.rawQuery(
    "PRAGMA table_info($table)"
  );
  return result.any((row) => row['name'] == column);
}

  Future<void> addDeck(DeckModel deck) async {
    
    final db = await instance.database;

      final deckId = await db.rawInsert(
      '''INSERT INTO $decksTable(${DeckFields.deckname}, ${DeckFields.numOfCards}) VALUES(?, ?)''', 
      [deck.deckname, deck.numOfCards]
    );

    for(final card in deck.listOfCards) {
      await db.rawInsert( 
        '''INSERT INTO $listTable(${CardFields.listDeckID}, ${CardFields.term}, ${CardFields.definition}) VALUES(?, ?, ?)''',
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

    //perform a join to get both tables mapped
    final decksData = await db.rawQuery(
      '''
      SELECT *
      FROM $decksTable 
      JOIN $listTable ON ${DeckFields.deckID} = ${CardFields.listDeckID}
      '''
    );

    //creates a map with the deck id as the key each deckid row will collect all the rows that share the same deckid
    Map<int, DeckModel> decksMap = {};
    

    for(final row in decksData) {
      final deckID = row[DeckFields.deckID] as int;

      //if the id is already added to the map then we add the cards to the list
      if(decksMap.containsKey(deckID)) {
        decksMap[deckID]!.listOfCards.add(
          CardModel(term: row[CardFields.term] as String,  
          definition: row[CardFields.definition] as String,
        )); 
      }
      //otherwise we create a new row in the map
      else {
        decksMap[deckID] = DeckModel(  
          deckname: row[DeckFields.deckname] as String,
          numOfCards: row[DeckFields.numOfCards] as int,
          listOfCards: [
            CardModel( 
              term: row[CardFields.term] as String,
              definition: row[CardFields.definition] as String,
            ),
          ]
        );
      }
      }
      List<DeckModel> decks = decksMap.values.toList();
      return decks;
  }

  Future<DeckModel> getDeckModelFromID(int id) async {
    final db = await instance.database;
    final deckRow = await db.rawQuery(  
      '''SELECT * FROM $decksTable 
      JOIN $listTable ON ${DeckFields.deckID} = ${CardFields.listDeckID}
      WHERE ${DeckFields.deckID} = ?''',
      [id]
    );
    String functionDeckname = deckRow.first[DeckFields.deckname] as String;
    int functionNumOfCards = deckRow.first[DeckFields.numOfCards] as int;

    List<CardModel>list = deckRow.map((card) => 
    CardModel(term: card[CardFields.term] as String, definition: card[CardFields.definition] as String)).toList();
    return DeckModel(deckname: functionDeckname, listOfCards: list, numOfCards: functionNumOfCards);
  }

  Future<DeckModel> getDeckModelFromName(String deckname) async {
    final db = await instance.database;

    //returns all of the cards of the deckname given
    final cardInDeck = await db.rawQuery(  
      '''SELECT * FROM $decksTable 
      JOIN $listTable ON ${DeckFields.deckID} = ${CardFields.listDeckID}
      WHERE ${DeckFields.deckname} = ? 
      ''', [deckname]
    );

    List<CardModel> list = [];
    //then we put all of these cards into a list 
    for(final card in cardInDeck) {
      list.add(CardModel(term: card[CardFields.term] as String, definition: card[CardFields.definition] as String));
    }
    
    //we return the deckmodel with the list we collected
    return DeckModel(deckname: cardInDeck.first[DeckFields.deckname] as String
      , listOfCards: list, numOfCards: cardInDeck.first[DeckFields.numOfCards] as int);
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


 //methods for displaying the top 10 times

}
