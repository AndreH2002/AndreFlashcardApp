import 'package:flutter/material.dart';
import '../models/deckmodel.dart';
import 'database_service.dart';

class DeckService with ChangeNotifier {
  DeckModel? _selectedModel;
  List<DeckModel> _listOfDecks = [];

  List<DeckModel> get listOfDecks => _listOfDecks;
  DeckModel? get selectedModel => _selectedModel;

Future<String> addDeck(DeckModel model) async {
  try{
    await DatabaseService.instance.addDeck(model);
    notifyListeners();
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

Future<String> removeDeck(int deckID) async {
  try {
    await DatabaseService.instance.removeDeck(deckID);
    notifyListeners();
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

Future<String> getDeckID(String name, int? id) async {
  try {
    id = await DatabaseService.instance.getDeckId(name);
    notifyListeners();
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

Future<String> getDeckModelFromID(int id) async {
  try {
    _selectedModel = await DatabaseService.instance.getDeckModelFromID(id);
    notifyListeners();
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

Future<String> getDeckModelFromName(String deckname) async {
  try {
    _selectedModel = await DatabaseService.instance.getDeckModelFromName(deckname);
  }
  catch(e) {
    _selectedModel = null;
    return e.toString();
  }
  return "OK";
}

Future<String> getDeckList() async {
  try {
    _listOfDecks = await DatabaseService.instance.getDecks();
   
  }
  catch(e) {
    return e.toString();
  }
  finally {
    notifyListeners();
  }
   
  return "OK";
}

Future<String> deckNameExists(String name) async {
  try {
    await DatabaseService.instance.deckNameExists(name);
    notifyListeners();
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

}