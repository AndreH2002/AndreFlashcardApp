import 'dart:collection';

import 'package:flutter/material.dart';
import '../models/deckmodel.dart';

class DeckProvider extends ChangeNotifier {
  final List<DeckModel> _listOfDecks = [];

  UnmodifiableListView<DeckModel>
    get listOfDecks => UnmodifiableListView(_listOfDecks);

void addToListOfDecks(DeckModel model) {
  _listOfDecks.add(model);
  notifyListeners();
}

void removeFromListOfDecks(DeckModel model) {
  _listOfDecks.remove(model);
  notifyListeners();
}


}