import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:revised_flashcard_application/models/cardmodel.dart';

class WritingWidget extends StatefulWidget {
  const WritingWidget(
      {super.key,
      required this.model,
      required this.solveForTerm,
      required this.onCorrect,
      required this.onWrong});

  final CardModel model;
  final bool solveForTerm;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  State<WritingWidget> createState() => _WritingWidgetState();
}

enum Status { typing, correct, incorrect }

class _WritingWidgetState extends State<WritingWidget> {
  late String term;
  late String definition;
  String? termImagePath;
  String? defImagePath;

  Status status = Status.typing;

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    term = widget.model.term;
    definition = widget.model.definition;
    termImagePath = widget.model.termImagePath;
    defImagePath = widget.model.defImagePath;
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
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                definition,
                textScaler: TextScaler.linear(2.0),
              ),
              SizedBox(height: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: _imageDisplay()
                ),
              ),
            ],
          ),
        ),
        Flexible(flex: 1, child: _displayedWidget()),
      ],
    );
  }

  Widget _displayedWidget() {
    if (status == Status.typing) {
      return TextField(
        decoration: InputDecoration(labelText: "Enter term"),
        controller: _controller,
        onSubmitted: (value) {
          _checkAnswer(_controller.text);
        },
      );
    } else if (status == Status.correct) {
      return _correct();
    } else {
      return _incorrect();
    }
  }

  void _checkAnswer(String text) {
  setState(() {
    if (_normalize(text) == _normalize(term)) {
      status = Status.correct;
      widget.onCorrect();
    } else {
      status = Status.incorrect;
      widget.onWrong();
    }
  });
}

String _normalize(String s) {
  return s.replaceAll(RegExp(r'[^a-z0-9]'), '').trim().toLowerCase();
}

  Widget _correct() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Correct!', style: TextStyle(color: Colors.redAccent)),
        Icon(Icons.check_box, color: Colors.greenAccent),
      ],
    );
  }

  Widget _incorrect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Incorrect!',
          style: TextStyle(color: Colors.redAccent),
        ),
        Icon(Icons.cancel, color: Colors.redAccent),
      ],
    );
  }

  Widget _imageDisplay() {
    String? imageName = widget.solveForTerm
        ? widget.model.defImagePath
        : widget.model.termImagePath;

    if (imageName == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: _getImageFile(imageName),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if(!snapshot.hasData || snapshot.data == null) {
          return const Icon(Icons.broken_image, size: 40, color: Colors.white);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            snapshot.data!,
            height: 150,
            width: 150,
          ),
        );
      }
    );
  }

  Future<File?> _getImageFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists() ? file : null;
  }
}
