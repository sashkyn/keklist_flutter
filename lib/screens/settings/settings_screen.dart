import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenmode/blocs/mark_bloc/mark_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:zenmode/screens/auth/auth_screen.dart';
import 'package:zenmode/storages/entities/mark.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  List<SettingItem> get _items => [
        SettingItem.supabaseTitle,
        _supabaseClient.auth.currentUser == null ? SettingItem.loginToSupabase : null,
        _supabaseClient.auth.currentUser != null ? SettingItem.logoutFromSupabase : null,
        SettingItem.otherThingsTitle,
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
        await _shareCSVFile(marks: state.values);
      }
    });
  }

  Future<void> _shareCSVFile({required List<Mark> marks}) async {
    final List<List<String>> csvEntryList = marks
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
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];

            switch (item.type) {
              case SettingItemType.title:
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 12.0,
                  ),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              case SettingItemType.disclosure:
              case SettingItemType.redDisclosure:
                return ListTile(
                  title: Text(item.title),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    switch (item) {
                      case SettingItem.exportToCSV:
                        // TODO: добавить блок настройкам и выполнение запроса на все марки
                        //context.read<MarkBloc>().add(GetMarksFromSupabaseStorageMarkEvent());
                        break;
                      case SettingItem.loginToSupabase:
                        await showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => const AuthScreen(),
                        );
                        setState(() {});
                        break;
                      case SettingItem.logoutFromSupabase:
                        await _supabaseClient.auth.signOut();
                        setState(() {});
                        break;
                      default:
                        break;
                    }
                  },
                );
            }
          }),
    );
  }
}

enum SettingItemType {
  title,
  disclosure,
  redDisclosure,
}

enum SettingItem {
  supabaseTitle(title: 'Supabase', type: SettingItemType.title),
  otherThingsTitle(title: 'Other things', type: SettingItemType.title),
  loginToSupabase(title: 'Login to Supabase', type: SettingItemType.disclosure),
  logoutFromSupabase(title: 'Logout from Supabase', type: SettingItemType.disclosure),
  exportToCSV(title: 'Export to CSV', type: SettingItemType.disclosure);

  const SettingItem({required this.title, required this.type});

  final String title;
  final SettingItemType type;
}
