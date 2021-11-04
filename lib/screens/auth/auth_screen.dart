// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _loginTextEditingController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            border: UnderlineInputBorder(),
            hintText: 'Login',
          ),
        ),
        TextField(
          controller: _passwordTextEditingController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(8),
            border: UnderlineInputBorder(),
            hintText: 'Password',
          ),
        ),
        ElevatedButton(
            child: Text('Login'),
            onPressed: () async {
              final UserCredential user = (await _auth.signInWithEmailAndPassword(
                email: _loginTextEditingController.text,
                password: _passwordTextEditingController.text,
              ));
              if (user != null) {
                print(user.user?.displayName);
              }
            }),
      ],
    );
  }
}
