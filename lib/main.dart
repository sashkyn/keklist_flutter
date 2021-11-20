import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/mark_collection/mark_collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();
  runApp(MyApp(app: app));
}

class MyApp extends StatefulWidget {

  final FirebaseApp app;

  const MyApp({Key? key, required this.app}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Emodzen',
      debugShowCheckedModeBanner: false,
      home: MarkCollectionScreen(),
    );
  }
}
