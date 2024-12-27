import 'package:flutter/material.dart';
import '../models/deckmodel.dart';
import 'database_service.dart';

class DeckService with ChangeNotifier {
  List<DeckModel> _listOfDecks = [];

  List<DeckModel> get listOfDecks => _listOfDecks;

Future<String> addDeck(DeckModel model) async {
  try{
    await DatabaseService.instance.addDeck(model);
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

Future<String> getDeckList() async {
  try {
    _listOfDecks = await DatabaseService.instance.getDecks();
    notifyListeners();
  }
  catch(e) {
    return e.toString();
  }
  return "OK";
}

}