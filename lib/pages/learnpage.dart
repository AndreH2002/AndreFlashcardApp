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

class _LearnPageState extends State<LearnPage> {

  late List<CardModel> listOfCards;
  late CardModel currentCard;
  late List<String>currentWrongTerms;

  late MultipleChoiceWidget currentMultipleChoice;
  WritingWidget? currentWritingWidget;

  late int unlearned;
  int learning = 0;
  int learned = 0;
  int round = 1;

  bool inGame = true;
  bool isMultipleChoice = true;
  bool done = false;

  @override
void initState() {
  super.initState();
  listOfCards = List.from(widget.deckModel.listOfCards);
  for(CardModel model in listOfCards) {
    model.learnStatus = LearnStatus.unlearned;
  }

  if (listOfCards.isNotEmpty) {
    //randomize the list
    listOfCards.shuffle();

    unlearned = listOfCards.length;

    //get the first card in the list and get 3 incorrect terms to throw into the multiple choice
    currentCard = listOfCards.first;
    currentWrongTerms = _getWrongTerms(currentCard.term!, currentCard.definition!);

    currentMultipleChoice = MultipleChoiceWidget(
      key:ValueKey(currentCard.term),
      definition: currentCard.definition!,
      correctTerm: currentCard.term!,
      wrongTerms: currentWrongTerms,
      isClickable: true,
      onCorrect: () {
       _onClicked(true);
      },
      onWrong: () {
        _onClicked(false);
      },
    );
  } else {
    // Handle empty card list case
    print("Deck is empty.");
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
            IconButton(onPressed: null, icon: Icon(Icons.settings), color: Colors.white,),
          ],
        )
      ),
      body: Container( 
        decoration: BoxDecoration( 
          gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent], 
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Expanded(
          child: inGame
              ?_setWidget()
              :progressWidget(),
        ),
      ),
    );
  }

  

    List<String> _getWrongTerms(String term, String definition) {
      List<CardModel>totalList = List.from(listOfCards);
      List<String>randomThree = [];
      totalList.removeWhere((e) => e.term == term);
      int n = 0;

      //creates a loop that gets the three random values
      while(n < 3 && totalList.isNotEmpty) {
        int randomIndex = Random().nextInt(totalList.length);
        randomThree.add(totalList.elementAt(randomIndex).term!);
        totalList.removeAt(randomIndex);
        n++;
      }
      return randomThree;
    }


    void _onClicked(bool isCorrect) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {

          if(isCorrect) {
            //the one unlearned card is now learning 
            learning++;
            unlearned--;
            currentCard.learnStatus = LearnStatus.learning;
          }

          int currentIndex = listOfCards.indexOf(currentCard);

          //if the list is longer than the current Index then switch the multiple choice widget to next in the list
          if(currentIndex < listOfCards.length - 1) {
            currentCard = listOfCards[currentIndex + 1];
           

            //if the next card is unlearned we set it to the next multiple choice to put in 
            if(currentCard.learnStatus == LearnStatus.unlearned) {
              _setToMultipleChoiceWidget();
            }

            //otherwise we set the next writing widget
            else {
              _setToWritingWidget();
            }
          }
          else {
            setState(() {
              inGame = false;
            });
            
          }
        });
      });
    }

    _onWritten(bool isCorrect) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          if(isCorrect) {
            learning --;
            learned++;
            currentCard.learnStatus = LearnStatus.unlearned;
          }

          int currentIndex = listOfCards.indexOf(currentCard);

          if(currentIndex < listOfCards.length - 1) {
            currentCard = listOfCards[currentIndex + 1];
            if(currentCard.learnStatus == LearnStatus.unlearned) {
              _setToMultipleChoiceWidget();
            }
            else {
              _setToWritingWidget();
            }
          if(isCorrect) {
            listOfCards.removeAt(currentIndex);
          }
          }
          else {
            if(isCorrect) {
              listOfCards.removeAt(currentIndex);
              if(listOfCards.isEmpty) {
                done =  true;
              }
            }
            inGame = false;
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
            child: Center(child: Text('Round complete', textScaler: TextScaler.linear(2.0),)),
          ),

          Padding(padding: const EdgeInsets.all(15.0),
          child: Text("$unlearned Unlearned")),

          Padding(padding: const EdgeInsets.all(15.0),
          child: Text("$learning Learning")),

          Padding(padding: const EdgeInsets.all(15.0),
          child: Text("$learned Learned")),

        
          done 
          ? playAgainButton()
          :nextRoundButton(),
        ],
      );
    }

    void _setNextRound() {
      setState(() {

        listOfCards.shuffle();
        currentCard = listOfCards.first;
        if(currentCard.learnStatus == LearnStatus.unlearned) {
          _setToMultipleChoiceWidget();
        }
        else {
          _setToWritingWidget();
        }
        inGame = true;
      });
    }

    void _setPlayAgain() {
      setState(() {
        //reset the list
        listOfCards = List.from(widget.deckModel.listOfCards);
        listOfCards.shuffle();

        currentCard = listOfCards.first;

        _setToMultipleChoiceWidget();

        inGame = true;
        done = false;

        unlearned = listOfCards.length;
        learning = 0;
        learned = 0;
      });
    }

    void _setToMultipleChoiceWidget() {
       currentWrongTerms = _getWrongTerms(currentCard.term!, currentCard.definition!);
       currentMultipleChoice = MultipleChoiceWidget(key: ValueKey(currentCard.term),
              definition: currentCard.definition!, correctTerm: currentCard.term!, wrongTerms: currentWrongTerms, isClickable: true,
                onCorrect: () {
                  _onClicked(true);
                },
                onWrong: () {
                  _onClicked(false);
                }
       );
       isMultipleChoice = true;
    }
    
    void _setToWritingWidget() {
      
      currentWritingWidget = WritingWidget(key: ValueKey(currentCard.term), term: currentCard.term!, definition: currentCard.definition!, 
              onCorrect: (){ 

                _onWritten(true);
              },
              onWrong: () {_onWritten(false);
              }) ;
      isMultipleChoice = false;
    }
    
    Widget _setWidget() {
     if(isMultipleChoice) {
      return currentMultipleChoice;
     }
     else {
      return currentWritingWidget!;
     }
    }

   

    Widget nextRoundButton() {
      return Center(
            child: ElevatedButton(onPressed: _setNextRound, 
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