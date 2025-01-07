import 'dart:math';
import 'package:flutter/material.dart';
import '../cards/matchcard.dart';
import 'cardmodel.dart';

class MatchGameModel {
  final int numOfCards;
  final List<CardModel> listOfCards;

  late final List<MatchCard> matchCardList;
  late final List<Color> colorList;
  late final List<bool> visibleList;

  final Color unclicked = Colors.blue;
  final Color clicked = Colors.purple;
  final Color matched = Colors.green;
  final Color wrong = Colors.red;

  MatchGameModel({
    required this.numOfCards,
    required this.listOfCards,
  }) {
    matchCardList = _generateMatchCardList();
    colorList = _generateParallelList(matchCardList);
    visibleList = _generateVisibilityList(matchCardList);
  }

  List<MatchCard> _generateMatchCardList() {
    int cardsLeft = numOfCards;
    List<CardModel> cardCopy = List.from(listOfCards);
    List<MatchCard> listToReturn = [];

    if (cardCopy.length <= 6) {
      for (int i = 0; i < cardsLeft; i++) {
        MatchCard term = MatchCard(text: cardCopy[i].term!);
        MatchCard definition = MatchCard(text: cardCopy[i].definition!);

        term.partner = definition;
        definition.partner = term;

        listToReturn.add(term);
        listToReturn.add(definition);
      }
    } else {
      while (cardsLeft > 0) {
        int randomIndex = Random().nextInt(cardsLeft);

        MatchCard term = MatchCard(text: cardCopy[randomIndex].term!);
        MatchCard definition = MatchCard(text: cardCopy[randomIndex].definition!);

        term.partner = definition;
        definition.partner = term;

        listToReturn.add(term);
        listToReturn.add(definition);

        var temp = cardCopy[randomIndex];
        cardCopy[randomIndex] = cardCopy[cardsLeft - 1];
        cardCopy[cardsLeft - 1] = temp;

        cardsLeft--;
      }
    }

    listToReturn.shuffle();
    return listToReturn;
  }

  List<Color> _generateParallelList(List<MatchCard> matchCardList) {
    return List<Color>.filled(matchCardList.length, unclicked);
  }

  List<bool> _generateVisibilityList(List<MatchCard> matchCardList) {
    return List<bool>.filled(matchCardList.length, true);
  }
}