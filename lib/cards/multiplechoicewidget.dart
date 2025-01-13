// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final String definition;
  final String correctTerm;
  final List<String> wrongTerms;

  final VoidCallback? onCorrect;
  final VoidCallback? onWrong;
  final VoidCallback?roundFinished;

  bool isClickable;

  MultipleChoiceWidget({
    super.key,
    required this.definition,
    required this.correctTerm,
    required this.wrongTerms,
    required this.isClickable,
    this.onCorrect,
    this.onWrong,
    this.roundFinished,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  late List<String> terms;
  late String correctTerm;
  late String definition;

  late bool isClickable;

  Map<String, Color> choiceColors = {};
  Map<String, Icon?> choiceIcons = {};

  @override
  void initState() {
    super.initState();
    terms = List.from(widget.wrongTerms)..add(widget.correctTerm);
    terms.shuffle();
    correctTerm = widget.correctTerm;
    definition = widget.definition;
    isClickable = widget.isClickable;

    // Initialize default colors and icons for all terms
    for (var term in terms) {
      choiceColors[term] = Colors.blueAccent;
      choiceIcons[term] = null;
    }
  }

  void handleChoice(String selectedTerm) {
    setState(() {
      // green if right
      if (selectedTerm == correctTerm) {
        choiceColors[selectedTerm] = Colors.greenAccent;
        choiceIcons[selectedTerm] = Icon(Icons.check_box, color: Colors.white);
        if (widget.onCorrect != null) widget.onCorrect!();
      } 
      //red if wrong
      else {
        choiceColors[selectedTerm] = Colors.redAccent;
        choiceIcons[selectedTerm] = Icon(Icons.remove_circle, color: Colors.white);
        if (widget.onWrong != null) widget.onWrong!();
      }

      // Disable all other choices
      for (var term in terms) {
        if (term != selectedTerm) {
          choiceColors[term] = Colors.grey;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraint) {
              final height = constraint.maxHeight;
              final width = constraint.maxWidth;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height, minWidth: width),
                  child: Center(
                    child: Text(
                      definition,
                      textScaler: TextScaler.linear(2.0),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Text('Select Answer'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: terms.length,
            itemBuilder: (context, index) {
              final term = terms[index];
              return GestureDetector(
                onTap: () {
                  if(isClickable) {
                    handleChoice(term);
                    isClickable = false;
                  }
                },
                child: choice(term),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget choice(String term) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.indigoAccent),
          color: choiceColors[term],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  term,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: choiceIcons[term] ?? Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
