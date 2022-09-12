// ignore_for_file: prefer_const_constructors_in_immutables, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// TODO: сделать механизм показа боттом шитов

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
          TextField(
            controller: _passwordTextEditingController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: UnderlineInputBorder(),
              hintText: 'Password',
            ),
          ),
          const SizedBox(height: 16.0),
          Visibility(
              visible: _groupValue == 0,
              child: _buildButton(
                text: 'Login',
                onPressed: () async {
                  try {
                    await _auth.signInWithEmailAndPassword(
                      email: _loginTextEditingController.text,
                      password: _passwordTextEditingController.text,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    final snackBar = SnackBar(content: Text('$e'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
              )),
          Visibility(
            visible: _groupValue == 1,
            child: _buildButton(
              text: 'Register',
              onPressed: () async {
                try {
                  await _auth.createUserWithEmailAndPassword(
                    email: _loginTextEditingController.text,
                    password: _passwordTextEditingController.text,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  // TODO: смаппить ошибки
                  ScaffoldMessenger.of(context).clearSnackBars();
                  final snackBar = SnackBar(content: Text('$e'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildButton({
    required String text,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      child: SizedBox(
        width: 100,
        height: 44,
        child: Center(child: Text(text)),
      ),
      style: ElevatedButton.styleFrom(primary: Colors.black),
      onPressed: onPressed,
    );
  }
}
