import 'cardmodel.dart';

class DeckModel {
  String deckname;
  List<CardModel>listOfCards;
  int numOfCards;


  DeckModel({
    required this.deckname,
    required this.listOfCards,
    required this.numOfCards,
  });
  
}