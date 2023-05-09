import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rememoji/blocs/auth_bloc/auth_bloc.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/constants.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/screens/auth/auth_screen.dart';
import 'package:rememoji/screens/web_page/web_page_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: разобраться с улучшенной навигацией во Flutter: go_router

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> with DisposeBag {
  bool _isLoggedIn = false;
  bool _offlineMode = false;

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(
      onNewState: (state) {
        setState(() {
          if (state is SettingsState) {
            _offlineMode = state.isOfflineMode;
          }
        });
      },
    )?.disposed(by: this);

    subscribeTo<AuthBloc>(
      onNewState: (state) {
        setState(() {
          if (state is AuthCurrentStatus) {
            _isLoggedIn = state.isLoggedIn;
          } else if (state is AuthLoggedIn) {
            _isLoggedIn = true;
          } else if (state is AuthLogouted) {
            _isLoggedIn = false;
          }
        });
      },
    )?.disposed(by: this);

    sendEventTo<AuthBloc>(AuthGetStatus());
    sendEventTo<SettingsBloc>(SettingsGet());
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
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Account'.toUpperCase()),
            tiles: [
              if (!_isLoggedIn)
                SettingsTile(
                  title: const Text('Login'),
                  leading: const Icon(Icons.login),
                  onPressed: (BuildContext context) {
                    _showAuthBottomSheet();
                  },
                ),
              if (_isLoggedIn)
                SettingsTile(
                  title: const Text('Logout'),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onPressed: (BuildContext context) {
                    context.read<AuthBloc>().add(AuthLogout());
                  },
                ),
            ],
          ),
          SettingsSection(
            title: Text('Data'.toUpperCase()),
            tiles: [
              SettingsTile.switchTile(
                initialValue: _offlineMode,
                leading: const Icon(Icons.cloud_off, color: Colors.grey),
                title: const Text('Offline mode'),
                onToggle: (bool value) async {
                  await _switchOfflineMode(value);
                },
              ),
              SettingsTile(
                title: const Text('Export to CSV'),
                leading: const Icon(Icons.file_download, color: Colors.brown),
                onPressed: (BuildContext context) {
                  sendEventTo<SettingsBloc>(SettingsExportAllMindsToCSV());
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('About'.toUpperCase()),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Whats new?'),
                leading: const Icon(Icons.new_releases, color: Colors.purple),
                onPressed: (BuildContext context) {
                  _showWhatsNew();
                },
              ),
              SettingsTile.navigation(
                title: const Text('Send feedback'),
                leading: const Icon(Icons.feedback, color: Colors.blue),
                onPressed: (BuildContext context) async {
                  await _sendFeedback();
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Danger zone'.toUpperCase()),
            tiles: [
              SettingsTile(
                title: const Text('Delete account'),
                leading: const Icon(Icons.delete, color: Colors.red),
                onPressed: (BuildContext context) async {
                  await _deleteAccount(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: KeklistConstants.feedbackEmail,
      query: 'subject=Feedback about Rememoji',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Are you sure?',
      message: 'If you delete yourself from system your minds will be deleted too.',
      cancelLabel: 'Cancel',
      okLabel: 'Delete me',
      isDestructiveAction: true,
    );
    switch (result) {
      case OkCancelResult.ok:
        sendEventTo<AuthBloc>(AuthDeleteAccount());
        break;
      case OkCancelResult.cancel:
        break;
    }
  }

  Future<void> _switchOfflineMode(bool value) async {
    // final result = await showDial(
    //   context: context,
    //   title: 'Are you sure?',
    //   message: 'If you switch offline mode on you will not be able to add new minds.',
    //   cancelLabel: 'Cancel',
    //   okLabel: 'Switch offline mode',
    //   isDestructiveAction: true,
    // );
    sendEventTo<SettingsBloc>(SettingsChangeOfflineMode(isOfflineMode: value));
  }

  @override
  void dispose() {
    super.dispose();

    cancelSubscriptions();
  }

  Future<void> _showWhatsNew() {
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (builder) {
        return WebPageScreen(
          title: 'Whats new?',
          initialUri: Uri.parse(KeklistConstants.whatsNewURL),
        );
      },
    );
  }

  Future<void> _showAuthBottomSheet() async {
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const AuthScreen(),
    );
  }
}
