import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zenmode/screens/auth/auth_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: _auth.currentUser == null,
            child: ElevatedButton(
              child: const Text('Enable sync'),
              onPressed: () async => await _showAuth(),
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

  _showAuth() async => await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => AuthScreen(),
      );
}
