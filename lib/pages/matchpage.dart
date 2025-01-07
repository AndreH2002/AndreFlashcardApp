import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/cards/matchcard.dart';
import 'package:revised_flashcard_application/finaltimedisplay.dart';
import 'package:revised_flashcard_application/matchtimer.dart';
import 'package:revised_flashcard_application/models/cardmodel.dart';
import 'package:revised_flashcard_application/models/matchgamemodel.dart';
import '../models/deckmodel.dart';

import '../services/timerprovider.dart';

class MatchPage extends StatefulWidget {
  final DeckModel deckModel;
  const MatchPage({super.key, required this.deckModel});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {



  bool displayFinal = false; //determines whether the final display should be shown
  
  late FinalTimeDisplay finalTime;
  
  late MatchGameModel currentModel;

  late int numOfCardsInModel; //total cards
  late List<CardModel>listOfCards; //list of all cards


  int numOfCardsToDisplay = 0; //how many cards will have their terms and defs displayed
  
  late int pairsLeft;

  MatchCard? clickedCard; //no cards initially clicked
  
  Color unclicked = Colors.blue;
  Color clicked = Colors.purple;
  Color matched = Colors.green;
  Color wrong = Colors.red;

  @override
  void initState() {
    super.initState();
    numOfCardsInModel = widget.deckModel.numOfCards;
    listOfCards = widget.deckModel.listOfCards;

    if(numOfCardsInModel <= 6) {
      numOfCardsToDisplay = numOfCardsInModel;
    }
    else {
      numOfCardsToDisplay = 6;
    }

    
}

@override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currentModel = MatchGameModel(numOfCards: numOfCardsToDisplay, listOfCards: listOfCards);

    finalTime = FinalTimeDisplay(
    time: 'N/A',
    playAgainButtonPressed: _setToPlayAgain, 
    goBackButtonPressed: _setToGoBack,
  );

    pairsLeft = numOfCardsToDisplay;
    WidgetsBinding.instance.addPostFrameCallback((_){
      _startTime();
    });
   
  }


  @override
  Widget build(BuildContext context) {
    //return PopScope to reset the timer when the back arrow is pressed midgame
    return PopScope(
      onPopInvokedWithResult: (didPop, dynamic) {
        context.read<TimerProvider>().resetTime();
      },
      child: Scaffold(  
       appBar: AppBar(  
         title: Row( 
           mainAxisAlignment: MainAxisAlignment.end,
           children: [
             MatchTimer(),
           ]
         )
       ),
       body: Column(
         children: [
      
           Visibility(visible: displayFinal, child: finalTime),
      
           Expanded(
             child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount
             (
               childAspectRatio: 0.71,
               crossAxisCount: 3
             ), 
             itemCount: currentModel.matchCardList.length,
             itemBuilder: (context, index) {
               return Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: GestureDetector(
                   onTap:() {
                     MatchCard currentCard = currentModel.matchCardList[index];
                     if(currentModel.colorList[index] == unclicked) {
                       _manageStatus(currentCard);
                     }
                   },
                   child: Visibility(
                     visible: currentModel.visibleList[index],
                     child: ColoredBox(
                       color: currentModel.colorList[index],
                       child: MatchCard( 
                       
                         text: currentModel.matchCardList[index].text,
                       ),
                     ),
                   ),
                 ),
               );
             }),
           ),
         ],
       )
            ),
    );
  }

  void _manageStatus(MatchCard card) {
      MatchCard? partner = card.partner;
      int cardIndex = currentModel.matchCardList.indexOf(card);
    
      if(clickedCard == null) {
        setState(() {
          clickedCard = card;
          currentModel.colorList[cardIndex] = clicked;
        });
      } 
      else {
        if(partner != null) {
          int partnerIndex = currentModel.matchCardList.indexOf(partner);
            if(clickedCard == partner && currentModel.colorList[partnerIndex] == clicked) {
              setState(() {
                currentModel.colorList[cardIndex] = matched;
                currentModel.colorList[partnerIndex] = matched;
                clickedCard = null;
                pairsLeft--;
                
              });

             if (pairsLeft == 0) {
              final timerProvider = context.read<TimerProvider>();
              timerProvider.stopTime();

            setState(() {
              displayFinal = true;
              finalTime.time = _formatTime(timerProvider.duration); 
            });
              timerProvider.resetTime();
            }

              
              Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  currentModel.visibleList[cardIndex] = false;
                  currentModel.visibleList[partnerIndex] = false;
                });
              });
              
            }
            else {
              int clickedIndex = currentModel.matchCardList.indexOf(clickedCard!);
              setState(() {
                currentModel.colorList[cardIndex] = wrong;
                currentModel.colorList[clickedIndex] = wrong;
              });

               Future.delayed(const Duration(milliseconds: 200), () {
                setState(() {
                  currentModel.colorList[cardIndex] = unclicked;
                  currentModel.colorList[clickedIndex] = unclicked;
                });
              });
            }
          }
          clickedCard = null;
        }
    }

    void _startTime() {
      context.read<TimerProvider>().startTime();
    }
  void _setToPlayAgain() {
      
    setState(() {
    
      displayFinal = false;
      pairsLeft = numOfCardsToDisplay; 
      clickedCard = null; 

    
      currentModel = MatchGameModel(numOfCards: numOfCardsToDisplay, listOfCards: listOfCards);

    
       for (int i = 0; i < currentModel.visibleList.length; i++) {
         currentModel.visibleList[i] = true;
        }

   
        for (int i = 0; i < currentModel.colorList.length; i++) {
          currentModel.colorList[i] = unclicked;
        }

        _startTime();

      });
    }

    void _setToGoBack() {
      setState(() {
        clickedCard = null; 
        Navigator.pop(context);
       
      });
       
    }

    String _formatTime(Duration duration) {
    String seconds = duration.inSeconds.toString();
    String milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 100).toString();

    return '$seconds.$milliseconds';
    }
  }

  

  

