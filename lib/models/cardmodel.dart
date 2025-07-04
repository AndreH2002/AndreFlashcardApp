class CardFields {
  static final String listID = "id";
  static final String listDeckID = "listDeckID";
  static final String term = "term";
  static final String definition = "definition";
  static final String termImagePath = "termImagePath";
  static final String defImagePath = "defImagePath";
}

class CardModel {
  int? listID;
  String term;
  String definition;
  String? termImagePath;
  String? defImagePath;
  LearnStatus? learnStatus;

  CardModel({
    required this.term,
    required this.definition,
    this.termImagePath,
    this.defImagePath,
    this.learnStatus,
    this.listID
  });
}

enum LearnStatus {
  unlearned, learning, learned
}
