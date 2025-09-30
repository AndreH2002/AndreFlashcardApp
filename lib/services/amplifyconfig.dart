import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:revised_flashcard_application/amplify_outputs.dart';


class AmplifyConfigService {
  static bool _configured = false;

  static Future<void> configureAmplify() async {
    if (_configured) return;

    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.configure(amplifyConfig);
      safePrint('Amplify successfully configured.');
      _configured = true;
    } on Exception catch (e) {
      safePrint('Error configuring Amplify: $e');
    }
  }
}

