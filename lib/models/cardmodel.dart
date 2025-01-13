class CardFields {
  static final String listID = "id";
  static final String listDeckID = "listDeckID";
  static final String term = "term";
  static final String definition = "definition";

}

class CardModel {
 
  String? term;
  String? definition;
  LearnStatus? learnStatus;

  CardModel({
    this.term,
    this.definition,
    this.learnStatus,
  });
}

enum LearnStatus {
  unlearned, learning, learned
}
