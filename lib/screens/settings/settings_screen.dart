import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emodzen/screens/auth/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Visibility(
            visible: _auth.currentUser == null,
            child: ElevatedButton(
              child: const Text('Enable sync'),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => AuthScreen(),
                );
              },
            ),
          ),
          Visibility(
            visible: _auth.currentUser != null,
            child: ElevatedButton(
              child: const Text('Logout'),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
