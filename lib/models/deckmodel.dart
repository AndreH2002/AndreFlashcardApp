import 'cardmodel.dart';

class DeckFields {
  static final String deckID = 'deckID';
  static final String deckname = 'deckname';
  static final String numOfCards = 'numOfCards';
  static final List<String> allFields = [deckID, deckname, numOfCards];
}

class DeckModel {
  int? deckID;
  String deckname;
  List<CardModel> listOfCards;
  int numOfCards;

  DeckModel({
    this.deckID,
    required this.deckname,
    required this.listOfCards,
    required this.numOfCards,
  });

  DeckModel copy({
    int? deckID,
    String? deckname,
    List<CardModel>? listOfCards,
    int? numOfCards,
  }) =>
      DeckModel(
        deckID: deckID ?? this.deckID,
        deckname: deckname ?? this.deckname,
        listOfCards: listOfCards ?? this.listOfCards,
        numOfCards: numOfCards ?? this.numOfCards,
      );
}
