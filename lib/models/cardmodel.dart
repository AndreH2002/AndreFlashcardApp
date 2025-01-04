class CardFields {
  static final String listID = "id";
  static final String listDeckID = "listDeckID";
  static final String term = "term";
  static final String definition = "definition";

}

class CardModel {
  String? term;
  String? definition;

  CardModel({
    this.term,
    this.definition
  });
}

