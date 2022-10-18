import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthWidgetState<T extends StatefulWidget> extends SupabaseAuthState<T> {
  @override
  void onUnauthenticated() {
    if (mounted) {
      showOkAlertDialog(
        context: context,
        title: 'Success',
        message: 'Logged out',
      );
      //Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  void onAuthenticated(Session session) {
    if (mounted) {
      showOkAlertDialog(
        context: context,
        title: 'Success',
        message: 'You are authentificated!',
      );
      // Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    }
  }

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onErrorAuthenticating(String message) {
    showOkAlertDialog(
      context: context,
      title: 'Error',
      message: message,
    );
  }
}
