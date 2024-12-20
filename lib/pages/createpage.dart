import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/models/cardmodel.dart';
import '../cards/creationcard.dart';
import '../models/deckmodel.dart';
import '../providers/provider.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.listOfCards});
  final List<CardModel>listOfCards;
  @override
  State<CreatePage> createState() => _CreatePageState();
}



class _CreatePageState extends State<CreatePage> {
  late String titleString;

  late List<CardModel>listOfCards;
  late DeckModel modelToSubmit;

  @override
  void initState() {
    // TODO: implement initState
    titleString =  "New Deck";
    listOfCards = widget.listOfCards;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(  

        //Row includes the name in a scroll view + the done button
        title: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(titleString),
                    
                  ],
                ),
              ),
            ),


            //Done button submits a DeckModel to the homepage
            ElevatedButton(  
                      onPressed:() => [
                        //get the deck in its model form
                        modelToSubmit = DeckModel(deckname: titleString, listOfCards: listOfCards, numOfCards: listOfCards.length),

                        //submit the deck using provider
                        context.read<DeckProvider>().addToListOfDecks(DeckModel(deckname: titleString, listOfCards: listOfCards, 
                        numOfCards: listOfCards.length)),

                        //go back to homepage
                        Navigator.pop(context),
                        
                      ],
                      child: const Text('Done'),
                    )
          ],
        ),
      ),
      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(  
              child: Column(  
                children: [  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(  
                      decoration:  
                        const InputDecoration(  
                          labelText: 'Title',
                        ),
                      textInputAction: TextInputAction.done,
                      onSubmitted:(value) => changeTitleString(value),
                      
                    ),
                  ),

                  //List view of all the creation cards
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: listOfCards.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0
                        ),
                        child: CreationCard(model: listOfCards.elementAt(index)),
                      );
                    }
                  ),
                ],
              )
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed:() => addCard(listOfCards), icon: const Icon(Icons.add)),
              IconButton(onPressed: () => removeCard(listOfCards), icon: const Icon(Icons.remove_circle)),
            ],
          )
        ],
      )
    );
  }

  void changeTitleString(value) {
    setState(() {
      titleString = value;
    });
  }

  void addCard(List<CardModel>modelList) {
    setState(() {
       modelList.add(CardModel());
    });
   
  }

  void removeCard(List<CardModel>modelList) {
    if(modelList.isNotEmpty) {
      setState(() {
        modelList.removeLast();
      });
    }
  }
}