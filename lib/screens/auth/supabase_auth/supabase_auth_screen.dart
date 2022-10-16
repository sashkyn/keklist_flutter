import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: сделать механизм показа боттом шитов

class SupabaseAuthScreen extends StatefulWidget {
  const SupabaseAuthScreen({Key? key}) : super(key: key);

  @override
  _SupabaseAuthScreenState createState() => _SupabaseAuthScreenState();
}

class _SupabaseAuthScreenState extends State<SupabaseAuthScreen> {
  final _loginTextEditingController = TextEditingController();

  final SupabaseClient _client = Supabase.instance.client;

  int _groupValue = 0;

  @override
  Widget build(BuildContext context) {
    Map<int, Widget> _children = {
      0: Center(
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 14,
            color: _groupValue == 0 ? Colors.black : Colors.white,
          ),
        ),
      ),
      1: Center(
        child: Text(
          'Registration',
          style: TextStyle(
            fontSize: 14,
            color: _groupValue == 1 ? Colors.black : Colors.white,
          ),
        ),
      ),
    };

    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Text(
              'Sign in',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          CupertinoSlidingSegmentedControl<int>(
            backgroundColor: Colors.black,
            thumbColor: Colors.white,
            padding: const EdgeInsets.all(8),
            groupValue: _groupValue,
            children: _children,
            onValueChanged: (value) {
              setState(() {
                _groupValue = value!;
              });
            },
          ),
          const SizedBox(height: 8.0),
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
              final response = await _client.auth.signIn(
                email: _loginTextEditingController.text,
                options: AuthOptions(
                  redirectTo: 'io.supabase.zenmode://login-callback/',
                ),
              );
              // TODO: показать алерт что нужно перейти на почту
              // TODO: сделать перехватчик диплинка              

              print(response);
            },
          ),
        ],
      ),
    );
  }
}
