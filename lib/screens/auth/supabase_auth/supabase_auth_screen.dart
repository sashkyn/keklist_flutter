import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthScreen extends StatefulWidget {
  const SupabaseAuthScreen({Key? key}) : super(key: key);

  @override
  SupabaseAuthScreenState createState() => SupabaseAuthScreenState();
}

class SupabaseAuthScreenState extends State<SupabaseAuthScreen> {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              await _client.auth.signInWithOtp(
                email: _loginTextEditingController.text,
                emailRedirectTo: 'io.supabase.zenmode://login-callback/'
              );
              showOkAlertDialog(
                context: context,
                title: 'Success',
                message: 'Please, go to your email app and open magic link',
              );
            },
            child: const SizedBox(
              width: 100,
              height: 44,
              child: Center(
                  child: Text(
                'Get magic link',
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
