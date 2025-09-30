import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revised_flashcard_application/services/amplifyconfig.dart';
import 'package:revised_flashcard_application/services/tts_provider.dart';
import 'pages/homepage.dart';
import 'package:revised_flashcard_application/services/deck_provider.dart';
import 'package:revised_flashcard_application/services/timer_provider.dart';
import 'services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  void initState() {
    super.initState();
    AmplifyConfigService.configureAmplify();
  }
  @override
  void dispose() {
    super.dispose();
    DatabaseService.instance.close();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DeckService(),
        ),
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TtsProvider(),
        ),
      ],
      child: Authenticator(
        child: MaterialApp(
          builder: Authenticator.builder(),
          home: HomePage(),
        ),
      ),
    );
  }
}
