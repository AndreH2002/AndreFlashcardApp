import 'package:flutter/material.dart';
import '../models/deckmodel.dart';
import 'database_service.dart';

enum DeckOperationStatus { success, failure}

class DeckService with ChangeNotifier {
  DeckModel? _selectedModel;
  List<DeckModel> _listOfDecks = [];

  List<DeckModel> get listOfDecks => _listOfDecks;
  DeckModel? get selectedModel => _selectedModel;

  Future<DeckOperationStatus> addDeck(DeckModel model) async {
    try {
      await DatabaseService.instance.addDeck(model);
      _listOfDecks = await DatabaseService.instance.getDecks();
      notifyListeners();
      return DeckOperationStatus.success;
    } catch (e) {
      debugPrint('Add deck error: $e');
      return DeckOperationStatus.failure;
    }
  }

  Future<DeckOperationStatus> removeDeck(int deckID) async {
    try {
      await DatabaseService.instance.removeDeck(deckID);
      _listOfDecks = await DatabaseService.instance.getDecks();
      notifyListeners();
      return DeckOperationStatus.success;
    } catch (e) {
      debugPrint('Remove deck error: $e');
      return DeckOperationStatus.failure;
    }
  }

  Future<int?> getDeckID(String name) async {
    try {
      return await DatabaseService.instance.getDeckId(name);
    } catch (e) {
      debugPrint('Get deck ID error: $e');
      return null;
    }
  }

  Future<DeckOperationStatus> getDeckModelFromID(int id) async {
    try {
      _selectedModel = await DatabaseService.instance.getDeckModelFromID(id);
      notifyListeners();
      return DeckOperationStatus.success;
    } catch (e) {
      debugPrint('Get deck model from ID error: $e');
      return DeckOperationStatus.failure;
    }
  }

  Future<DeckOperationStatus> getDeckModelFromName(String deckname) async {
    try {
      _selectedModel = await DatabaseService.instance.getDeckModelFromName(deckname);
      notifyListeners();
      return DeckOperationStatus.success;
    } catch (e) {
      debugPrint('Get deck model from name error: $e');
      _selectedModel = null;
      return DeckOperationStatus.failure;
    }
  }

  Future<DeckOperationStatus> getDeckList() async {
    debugPrint('DeckService: getDeckList called');
    try {
      _listOfDecks = await DatabaseService.instance.getDecks();
      debugPrint('Fetched ${_listOfDecks.length} decks');
      notifyListeners();
      return DeckOperationStatus.success;
    } catch (e, stackTrace) {
      debugPrint('getDeckList error: $e');
       debugPrintStack(stackTrace: stackTrace);

      return DeckOperationStatus.failure;
    }
  }

  Future<bool?> deckNameExists(String name) async {
    try {
      return await DatabaseService.instance.deckNameExists(name);
    } catch (e) {
      debugPrint('deckNameExists error: $e');
      return null;
    }
  }
}