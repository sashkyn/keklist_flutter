import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/helpers/auth_state.dart';

class SupabaseAuthScreen extends StatefulWidget {
  const SupabaseAuthScreen({Key? key}) : super(key: key);

  @override
  _SupabaseAuthScreenState createState() => _SupabaseAuthScreenState();
}

class _SupabaseAuthScreenState extends AuthWidgetState<SupabaseAuthScreen> {
  final _loginTextEditingController = TextEditingController();

  final SupabaseClient _client = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: Text(
              'Sign in',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextField(
            controller: _loginTextEditingController,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: UnderlineInputBorder(),
              hintText: 'Email',
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: const SizedBox(
              width: 100,
              height: 44,
              child: Center(
                  child: Text(
                'Get magic link',
                style: TextStyle(color: Colors.white),
              )),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              await _client.auth.signIn(
                email: _loginTextEditingController.text,
                options: AuthOptions(
                  redirectTo: 'io.supabase.zenmode://login-callback/',
                ),
              );
              showOkAlertDialog(
                context: context,
                title: 'Success',
                message: 'Go to your email app and open magic link',
              );
            },
          ),
        ],
      ),
    );
  }
}
