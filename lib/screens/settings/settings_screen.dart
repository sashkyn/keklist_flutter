import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/blocs/mark_bloc/mark_bloc.dart';
import 'package:zenmode/helpers/auth_state.dart';
import 'package:zenmode/screens/auth/firebase_auth/firebase_auth_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:zenmode/screens/auth/supabase_auth/supabase_auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends AuthWidgetState<SettingsScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  List<SettingItem> get _items => [
        _firebaseAuth.currentUser == null ? SettingItem.loginToFirebase : null,
        _supabaseClient.auth.currentUser == null ? SettingItem.loginToSupabase : null,
        _firebaseAuth.currentUser != null ? SettingItem.logoutFromFirebase : null,
        _supabaseClient.auth.currentUser != null ? SettingItem.logoutFromSupabase : null,
        SettingItem.exportToCSV,
      ]
          .where((element) => element != null)
          .map(
            (nullableItem) => nullableItem!,
          )
          .toList(growable: false);

  @override
  void initState() {
    super.initState();

    context.read<MarkBloc>().stream.listen((state) async {
      if (state is ListMarkState) {
        final List<List<String>> csvEntryList = state.values
            .map(
              (e) => e.toCSVEntry(),
            )
            .toList(growable: false);
        final String csv = const ListToCsvConverter().convert(csvEntryList);
        final Directory temporaryDirectory = await getTemporaryDirectory();
        final File csvFile = File('${temporaryDirectory.path}/user_data.csv');
        await csvFile.writeAsString(csv);
        final XFile fileToShare = XFile(csvFile.path);
        await Share.shareXFiles([fileToShare]);
      }
    });
  }

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
      body: ListView.builder(
        // Let the ListView know how many items it needs to build.
        itemCount: _items.length,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final item = _items[index];

          return ListTile(
            title: Text(item.title),
            trailing: const Icon(Icons.arrow_circle_right_outlined),
            onTap: () async {
              switch (item) {
                case SettingItem.loginToFirebase:
                  await showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => FirebaseAuthScreen(),
                  );
                  setState(() {});
                  break;
                case SettingItem.logoutFromFirebase:
                  await _firebaseAuth.signOut();
                  setState(() {});
                  break;
                case SettingItem.exportToCSV:
                  context.read<MarkBloc>().add(GetMarksFromAllStoragesMarkEvent());
                  break;
                case SettingItem.loginToSupabase:
                  await showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => const SupabaseAuthScreen(),
                  );
                  setState(() {});
                  break;
                case SettingItem.logoutFromSupabase:
                  await _supabaseClient.auth.signOut();
                  setState(() {});
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

enum SettingItem {
  loginToFirebase(title: 'Login to Firebase', type: SettingItemType.disclosure),
  loginToSupabase(title: 'Login to Supabase', type: SettingItemType.disclosure),
  logoutFromFirebase(title: 'Logout from Firebase', type: SettingItemType.disclosure),
  logoutFromSupabase(title: 'Logout from Supabase', type: SettingItemType.disclosure),
  exportToCSV(title: 'Export to CSV', type: SettingItemType.disclosure);

  const SettingItem({required this.title, required this.type});

  final String title;
  final SettingItemType type;
}

enum SettingItemType { disclosure, redDisclosure }
