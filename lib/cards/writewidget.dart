import 'package:flutter/material.dart';

class WritingWidget extends StatefulWidget {
  const WritingWidget({super.key, required this.term, required this.definition, 
  required this.onCorrect, required this.onWrong});

  final String definition;
  final String term;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  State<WritingWidget> createState() => _WritingWidgetState();
}

enum Status{ 
  typing, correct, incorrect
}

class _WritingWidgetState extends State<WritingWidget> {
  late String term;
  late String definition;
  
  Status status = Status.typing;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    term = widget.term;
    definition = widget.definition;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column( 
      children: [ 
        Flexible(flex: 1, child: Container()),
        Flexible(flex: 1, child: Text(definition, textScaler: TextScaler.linear(2.0),)),
       
        Flexible(flex: 1, 
        child: _displayedWidget()
        ),
          
      ],
    );
  }

  Widget _displayedWidget() {
    if(status == Status.typing) {
      return TextField(
          decoration: InputDecoration(
            labelText: "Enter term"
          ),
          controller: _controller,
          onSubmitted: (value) {
            _checkAnswer(_controller.text);
          },
          );
    }
    else if (status == Status.correct) {
      return _correct();
    }
    else {
      return _incorrect();
    }
  }


  void _checkAnswer(String text) {
    setState(() {
      if(text.toLowerCase() == term.toLowerCase()) {
      status = Status.correct;
      widget.onCorrect();
    }
    else {
      status = Status.incorrect;
      widget.onWrong();
    }
    });
    
  }

  Widget _correct() {
    return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [ 
      Text('Correct!', style: TextStyle(color: Colors.redAccent)),
      Icon(Icons.check_box, color: Colors.greenAccent),
    ],);
  }

  Widget _incorrect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ 
        Text('Incorrect!', style: TextStyle(color: Colors.redAccent),),
        Icon(Icons.cancel, color: Colors.redAccent),
      ],
    );
  }
}