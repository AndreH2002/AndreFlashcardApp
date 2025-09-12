import 'dart:io';

import 'package:flutter/material.dart';
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

    final dbFile = File(databasePath);
    final exists = await dbFile.exists();

    debugPrint('💾 DB path: $databasePath');
    debugPrint('✅ DB file exists before opening? $exists');

    final database = await openDatabase(
      databasePath,
      version: 4,
      onConfigure: _onConfigure,
      onCreate: (db, version) async {
        debugPrint('🛠️ Running _onCreate: creating tables...');
        await _onCreate(db, version);
      },
      onUpgrade: _onUpgrade,
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
          ${CardFields.termImagePath} TEXT,
          ${CardFields.defImagePath} TEXT,
          FOREIGN KEY (${CardFields.listDeckID}) REFERENCES $decksTable (${DeckFields.deckID}) ON DELETE CASCADE
        )
        ''');
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.rawQuery('PRAGMA journal_mode = WAL');
  }

  Future _onUpgrade(Database db, oldVersion, newVersion) async {
    if (oldVersion < 4) {
      await db.transaction((txn) async {
        await txn.delete(listTable);
        await txn.delete(decksTable);
      });
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  //used to check for a duplicate name on a deck
  Future<bool> columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery("PRAGMA table_info($table)");
    return result.any((row) => row['name'] == column);
  }

  Future<DeckModel> addDeck(DeckModel deck) async {
    final db = await instance.database;

    late int deckID;
    await db.transaction((txn) async {
      //first part inserts the name and the number of cards into the table and returns the id

      deckID = await txn.rawInsert(
          '''INSERT INTO $decksTable(${DeckFields.deckname}, ${DeckFields.numOfCards}) VALUES(?, ?)''',
          [deck.deckname, deck.numOfCards]);

      /*
        this part loops through every card in the deck and puts it in the list of all the total cards linking it with it
        its deck through the listDeckID which ids which deck it comes from
      */
      for (final card in deck.listOfCards) {
        final listId = await txn.rawInsert(
            '''INSERT INTO $listTable(${CardFields.listDeckID}, ${CardFields.term}, ${CardFields.definition}, ${CardFields.termImagePath}, ${CardFields.defImagePath}) VALUES(?, ?, ?, ?, ?)''',
            [
              deckID,
              card.term,
              card.definition,
              card.termImagePath,
              card.defImagePath
            ]);
        card.listID = listId;
      }
    });
    return deck.copy(deckID: deckID);
  }

  Future<void> removeDeck(int deckId) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.rawDelete(
          'DELETE FROM $listTable WHERE ${CardFields.listDeckID} = ?',
          [deckId]);
      await txn.rawDelete(
          'DELETE FROM $decksTable WHERE ${DeckFields.deckID} = ?', [deckId]);
    });
  }

  Future<int> getDeckId(String name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT * FROM $decksTable WHERE ${DeckFields.deckname} = ?', [name]);
    if (result.isNotEmpty) {
      return result.first[DeckFields.deckID] as int;
    } else {
      return -1;
    }
  }

  Future<List<DeckModel>> getDecks() async {
    debugPrint('DatabaseService.getDecks called');
    final db = await instance.database;

    debugPrint('Fetching decks from DB...');
    //performs a join to get both tables mapped
    final decksData = await db.rawQuery('''
      SELECT *
      FROM $decksTable 
      JOIN $listTable ON ${DeckFields.deckID} = ${CardFields.listDeckID}
      ''');

    //creates a map with the deck id as the key each deckid row will collect all the rows that share the same deckid
    Map<int, DeckModel> decksMap = {};

    for (final row in decksData) {
      final deckID = row[DeckFields.deckID] as int;

      //if the id is already added to the map then the cards are added  to the list
      if (decksMap.containsKey(deckID)) {
        decksMap[deckID]!.listOfCards.add(CardModel(
              term: row[CardFields.term] as String,
              definition: row[CardFields.definition] as String,
              termImagePath: row[CardFields.termImagePath] as String?,
              defImagePath: row[CardFields.defImagePath] as String?,
            ));
      }
      //creates a new row in the map if not added
      else {
        decksMap[deckID] = DeckModel(
            deckID: deckID,
            deckname: row[DeckFields.deckname] as String,
            numOfCards: row[DeckFields.numOfCards] as int,
            listOfCards: [
              CardModel(
                term: row[CardFields.term] as String,
                definition: row[CardFields.definition] as String,
                termImagePath: row[CardFields.termImagePath] as String?,
                defImagePath: row[CardFields.defImagePath] as String?,
              ),
            ]);
      }
    }
    List<DeckModel> decks = decksMap.values.toList();
    debugPrint('Decks fetched: ${decksData.length}');
    return decks;
  }

  Future<DeckModel> getDeckModelFromID(int id) async {
    final db = await instance.database;
    final deckRow = await db.rawQuery('''SELECT * FROM $decksTable 
      JOIN $listTable ON ${DeckFields.deckID} = ${CardFields.listDeckID}
      WHERE ${DeckFields.deckID} = ?''', [id]);
    String functionDeckname = deckRow.first[DeckFields.deckname] as String;
    int functionNumOfCards = deckRow.first[DeckFields.numOfCards] as int;

    List<CardModel> list = deckRow
        .map((card) => CardModel(
            term: card[CardFields.term] as String,
            definition: card[CardFields.definition] as String,
            termImagePath: card[CardFields.termImagePath] as String?,
            defImagePath: card[CardFields.defImagePath] as String?))
        .toList();
    return DeckModel(
        deckname: functionDeckname,
        listOfCards: list,
        numOfCards: functionNumOfCards);
  }

  Future<DeckModel> getDeckModelFromName(String deckname) async {
    final db = await instance.database;

    //returns all of the cards of the deckname given
    final cardInDeck = await db.rawQuery('''SELECT * FROM $decksTable 
      JOIN $listTable ON ${DeckFields.deckID} = ${CardFields.listDeckID}
      WHERE ${DeckFields.deckname} = ? 
      ''', [deckname]);

    List<CardModel> list = [];
    //then we put all of these cards into a list
    for (final card in cardInDeck) {
      list.add(CardModel(
          term: card[CardFields.term] as String,
          definition: card[CardFields.definition] as String,
          termImagePath: card[CardFields.termImagePath] as String?,
          defImagePath: card[CardFields.defImagePath] as String?));
    }

    //we return the deckmodel with the list we collected
    return DeckModel(
        deckname: cardInDeck.first[DeckFields.deckname] as String,
        listOfCards: list,
        numOfCards: cardInDeck.first[DeckFields.numOfCards] as int);
  }

  Future<List<CardModel>> getCards(int deckID) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT * FROM $listTable WHERE ${CardFields.listDeckID} = ?',
        [deckID]);
    return result
        .map((e) => CardModel(
              term: e[CardFields.term] as String,
              definition: e[CardFields.definition] as String,
              termImagePath: e[CardFields.termImagePath] as String?,
              defImagePath: e[CardFields.defImagePath] as String?,
            ))
        .toList();
  }

  Future<bool> deckNameExists(String name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT * FROM $decksTable WHERE ${DeckFields.deckname} = ?', [name]);
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateDeck(DeckModel updatedDeck) async {
    final db = await instance.database;

    if (updatedDeck.deckID == null) {
      debugPrint("❌ ERROR: Deck ID is null before inserting cards!");
      throw Exception("Deck ID is null during update");
    }

    await db.transaction((txn) async {
      // Update deck name and numOfCards
      await txn.update(
        decksTable,
        {
          DeckFields.deckname: updatedDeck.deckname,
          DeckFields.numOfCards: updatedDeck.listOfCards.length,
        },
        where: '${DeckFields.deckID} = ?',
        whereArgs: [updatedDeck.deckID],
      );

      // Delete old cards
      await txn.delete(
        listTable,
        where: '${CardFields.listDeckID} = ?',
        whereArgs: [updatedDeck.deckID],
      );

      // Insert new cards
      for (final card in updatedDeck.listOfCards) {
        await txn.insert(listTable, {
          CardFields.listDeckID: updatedDeck.deckID,
          CardFields.term: card.term,
          CardFields.definition: card.definition,
          CardFields.termImagePath: card.termImagePath,
          CardFields.defImagePath: card.defImagePath,
        });
      }
    });
  }

  //methods for displaying the top 10 times
}
