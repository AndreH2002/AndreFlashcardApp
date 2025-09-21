import 'dart:math';
import 'package:flutter/material.dart';
import 'package:revised_flashcard_application/cards/multiplechoicewidget.dart';
import '../cards/writewidget.dart';
import '../models/cardmodel.dart';
import '../models/deckmodel.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key, required this.deckModel});
  final DeckModel deckModel;

  @override
  State<LearnPage> createState() => _LearnPageState();
}

enum GameStatus{inGame, inBetween, done}
enum TypeStatus{multipleChoice, writing}

class _LearnPageState extends State<LearnPage> {
  late List<CardModel> listOfCards;
  late CardModel currentCard;
  late List<String> currentWrongTerms;

  late Widget currentWidget;

  //set the ints
  late int unlearned;
  int learning = 0;
  int learned = 0;
  int round = 1;


  //define game and type status
  late GameStatus gameStatus; 
  late TypeStatus typeStatus;

  //set the bools
  bool solveForTerm = true;

  @override
  void initState() {
    super.initState();
    listOfCards = List.from(widget.deckModel.listOfCards);

    gameStatus = GameStatus.inGame;
    typeStatus = TypeStatus.multipleChoice;

    for (CardModel model in listOfCards) {
      model.learnStatus = LearnStatus.unlearned;
    }

    if (listOfCards.isNotEmpty) {
      //randomize the list
      listOfCards.shuffle();

      unlearned = listOfCards.length;

      //get the first card in the list and get 3 incorrect terms to throw into the multiple choice
      currentCard = listOfCards.first;
      currentWrongTerms =
          _getWrongTerms(currentCard.term, currentCard.definition);

      currentWidget = MultipleChoiceWidget(
        key: ValueKey(currentCard.term),
        definition: currentCard.definition,
        correctTerm: currentCard.term,
        wrongTerms: currentWrongTerms,
        isClickable: true,
        solveForTerm: solveForTerm,
        model: currentCard,
        onCorrect: () {
          _onClicked(true);
        },
        onWrong: () {
          _onClicked(false);
        },
      );
    } else {
      // Handle empty card list case
      debugPrint("Deck is empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //TODO: obtain the round information
              //TODO: make a settings widget
              Text('Learn', style: TextStyle(color: Colors.white)),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.settings),
                color: Colors.white,
              ),
            ],
          )),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: gameStatus == GameStatus.inGame ? currentWidget : progressWidget(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getWrongTerms(String term, String definition) {
    List<CardModel> totalList = List.from(listOfCards);
    List<String> randomSelections = [];
    totalList.removeWhere((e) => e.term == term);
    int n = 0;
    int numWrongCount = 0;

    if(listOfCards.length > 3) {
      numWrongCount = 3;
    }
    else {
      numWrongCount = listOfCards.length - 1;
    }
    //creates a loop that gets the three random values or less if there aren't as many cards
    while (n < numWrongCount && totalList.isNotEmpty) {
      int randomIndex = Random().nextInt(totalList.length);
      randomSelections.add(totalList.elementAt(randomIndex).term);
      totalList.removeAt(randomIndex);
      n++;
    }
    return randomSelections;
  }

  void _onClicked(bool isCorrect) {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (isCorrect) {
          //the one unlearned card is now learning
          learning++;
          unlearned--;
          currentCard.learnStatus = LearnStatus.learning;
        }

        int currentIndex = listOfCards.indexOf(currentCard);

        //if the list is longer than the current Index then switch the multiple choice widget to next in the list
        if (currentIndex < listOfCards.length - 1) {
          currentCard = listOfCards[currentIndex + 1];

          //if the next card is unlearned we set it to the next multiple choice to put in
          if (currentCard.learnStatus == LearnStatus.unlearned) {
            _setToMultipleChoiceWidget();
          }

          //otherwise we set the next writing widget
          else {
            _setToWritingWidget();
          }
        } else {
            if(listOfCards.isEmpty) {
              setState(() {
                gameStatus = GameStatus.done;
              });
            }
            else {
              gameStatus = GameStatus.inBetween;
            }
        }
      });
    });
  }

  _onWritten(bool isCorrect) {
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        if (isCorrect) {
          learning--;
          learned++;
          currentCard.learnStatus = LearnStatus.learned;
        }

        int currentIndex = listOfCards.indexOf(currentCard);

        if (currentIndex < listOfCards.length - 1) {
          currentCard = listOfCards[currentIndex + 1];
          if (currentCard.learnStatus == LearnStatus.unlearned) {
            _setToMultipleChoiceWidget();
          } else {
            _setToWritingWidget();
          }
          if (isCorrect) {
            listOfCards.removeAt(currentIndex);
          }
        } else {
          if (isCorrect) {
            listOfCards.removeAt(currentIndex);
            
          }
          if (listOfCards.isEmpty) {
              gameStatus = GameStatus.done;
            }
            else {
              gameStatus = GameStatus.inBetween;
            }
         
        }
      });
    });
  }

  //TODO: We need to track the number of correct answers on a particular CardModel

  Widget progressWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
              child: Text(
            'Round complete',
            textScaler: TextScaler.linear(2.0),
          )),
        ),
        Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("$unlearned Unlearned")),
        Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("$learning Learning")),
        Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("$learned Learned")),
        gameStatus == GameStatus.done ? playAgainButton() : nextRoundButton(),
      ],
    );
  }

  void _setNextRound() {
    setState(() {
     
      listOfCards.shuffle();
      currentCard = listOfCards.first;
      if (currentCard.learnStatus == LearnStatus.unlearned) {
        _setToMultipleChoiceWidget();
      } else {
        _setToWritingWidget();
      }
      gameStatus = GameStatus.inGame;
    });
  }

  void _setPlayAgain() {
    setState(() {
      //reset the list
      listOfCards = List.from(widget.deckModel.listOfCards);
       for(CardModel card in listOfCards) {
        card.learnStatus = LearnStatus.unlearned;
      }
      listOfCards.shuffle();

      currentCard = listOfCards.first;

      _setToMultipleChoiceWidget();

      gameStatus = GameStatus.inGame;

      unlearned = listOfCards.length;
      learning = 0;
      learned = 0;
    });
  }

  void _setToMultipleChoiceWidget() {
    currentWrongTerms =
        _getWrongTerms(currentCard.term, currentCard.definition);
    currentWidget = MultipleChoiceWidget(
        key: ValueKey(currentCard.term),
        definition: currentCard.definition,
        correctTerm: currentCard.term,
        wrongTerms: currentWrongTerms,
        isClickable: true,
        solveForTerm: solveForTerm,
        model: currentCard,
        onCorrect: () {
          _onClicked(true);
        },
        onWrong: () {
          _onClicked(false);
        });
    typeStatus = TypeStatus.multipleChoice;
  }

  void _setToWritingWidget() {
    currentWidget = WritingWidget(
        key: ValueKey(currentCard.term),
        model: currentCard,
        solveForTerm: solveForTerm,
        onCorrect: () {
          _onWritten(true);
        },
        onWrong: () {
          _onWritten(false);
        });
    typeStatus = TypeStatus.writing;
  }

  Widget nextRoundButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _setNextRound,
        child: Text('Continue to the next round'),
      ),
    );
  }

  Widget playAgainButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _setPlayAgain,
        child: Text('Click to play again'),
      ),
    );
  }

  
}
