import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/homepage.dart';
import 'package:revised_flashcard_application/providers/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create:(context) => DeckProvider(),
          child: const MaterialApp(
            home: HomePage(),
          ),
      );
  }
}
