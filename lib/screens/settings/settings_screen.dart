import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:zenmode/blocs/auth_bloc/auth_bloc.dart';
import 'package:zenmode/blocs/settings_bloc/settings_bloc.dart';
import 'package:zenmode/screens/auth/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggedIn = false;

  List<SettingItem> get _items => [
        SettingItem.userTitle,
        !_isLoggedIn ? SettingItem.login : null,
        _isLoggedIn ? SettingItem.logout : null,
        _isLoggedIn ? SettingItem.deleteAccount : null,
        SettingItem.otherTitle,
        SettingItem.exportToCSV,
      ].where((element) => element != null).map((nullableItem) => nullableItem!).toList(growable: false);

  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().stream.listen((state) async {
      setState(() {
        if (state is CurrentUserAuthStatus) {
          _isLoggedIn = state.isLoggedIn;
        } else if (state is LoggedIn) {
          _isLoggedIn = true;
        } else if (state is Logouted) {
          _isLoggedIn = false;
        }
      });
    });

    context.read<AuthBloc>().add(GetAuthStatus());
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
                        context.read<SettingsBloc>().add(ExportMarksToCSVSettingsEvent());
                        break;
                      case SettingItem.login:
                        await showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => const AuthScreen(),
                        );
                        setState(() {});
                        break;
                      case SettingItem.logout:
                        context.read<AuthBloc>().add(Logout());
                        setState(() {});
                        break;
                      case SettingItem.deleteAccount:
                        // TODO: удалить аккаунт реально
                        // TODO: показать алерт
                        // TODO: предложить сохранить эмоции перед удалением
                        context.read<AuthBloc>().add(Logout());
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
  userTitle(title: 'User', type: SettingItemType.title),
  otherTitle(title: 'Other', type: SettingItemType.title),
  login(title: 'Login to Supabase', type: SettingItemType.disclosure),
  logout(title: 'Logout from Supabase', type: SettingItemType.disclosure),
  exportToCSV(title: 'Export to CSV', type: SettingItemType.disclosure),
  interface(title: 'Interface', type: SettingItemType.disclosure),
  deleteAccount(title: 'Delete your account', type: SettingItemType.redDisclosure);

  const SettingItem({required this.title, required this.type});

  final String title;
  final SettingItemType type;
}
