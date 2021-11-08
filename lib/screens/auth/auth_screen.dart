// ignore_for_file: prefer_const_constructors_in_immutables, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Object? _currentSelection = 0;

  @override
  Widget build(BuildContext context) {
    const Map<int, Widget> _children = {
      0: Center(child: Text('Login')),
      1: Text('Registration'),
    };

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          MaterialSegmentedControl(
            children: _children,
            selectionIndex: _currentSelection,
            borderColor: Colors.grey,
            selectedColor: Colors.blue,
            unselectedColor: Colors.white,
            borderRadius: 32.0,
            onSegmentChosen: (index) {
              setState(() => _currentSelection = index);
            },
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _loginTextEditingController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: UnderlineInputBorder(),
              hintText: 'Email',
            ),
          ),
          TextField(
            controller: _passwordTextEditingController,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8),
              border: UnderlineInputBorder(),
              hintText: 'Password',
            ),
          ),
          const SizedBox(height: 8.0),
          Visibility(
            visible: _currentSelection == 0,
            child: ElevatedButton(
              child: const Text('Login'),
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
            ),
          ),
          Visibility(
            visible: _currentSelection == 1,
            child: ElevatedButton(
              child: const Text('Register'),
              onPressed: () async {
                try {
                  await _auth.createUserWithEmailAndPassword(
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
            ),
          ),
        ],
      ),
    );
  }
}
