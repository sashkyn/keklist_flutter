import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keklist/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/auth/auth_screen.dart';
import 'package:keklist/presentation/screens/web_page/web_page_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: move methods from MindBloc to SettingsBloc (in progress)
// TODO: darkmode: add system mode

final class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

final class SettingsScreenState extends KekWidgetState<SettingsScreen> {
  bool _isLoggedIn = false;
  bool _offlineMode = false;
  bool _isDarkMode = false;
  bool _showTitles = true;
  int _cachedMindCountToUpload = 0;
  bool _clearCacheVisible = true;
  String _openAiKey = '';

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(onNewState: (state) {
      switch (state) {
        case SettingsDataState state:
          setState(() {
            _isLoggedIn = state.isLoggedIn;
            _cachedMindCountToUpload = state.offlineMinds.length;
            _offlineMode = state.settings.isOfflineMode;
            _isDarkMode = state.settings.isDarkMode;
            _openAiKey = state.settings.openAIKey ?? '';
            _showTitles = state.settings.shouldShowTitles;
          });
          break;
        case SettingsLoadingState state:
          if (state.isLoading) {
            EasyLoading.show();
          } else {
            EasyLoading.dismiss();
          }
          break;
        case SettingsUploadOfflineMindsErrorState _:
          EasyLoading.dismiss();
          showOkAlertDialog(
            context: context,
            title: 'Error',
            message: 'Could not upload minds.',
          );
          break;
        case SettingsUploadOfflineMindsCompletedState _:
          sendEventTo<SettingsBloc>(SettingsGet());
      }
    })?.disposed(by: this);

    subscribeTo<MindBloc>(onNewState: (state) {
      switch (state.runtimeType) {
        case const (MindServerOperationStarted):
          if (state.type == MindOperationType.uploadCachedData ||
              state.type == MindOperationType.deleteAll ||
              state.type == MindOperationType.clearCache) {
            EasyLoading.show();
          }
        case const (MindOperationError):
          if (state.notCompleted == MindOperationType.uploadCachedData ||
              state.notCompleted == MindOperationType.clearCache ||
              state.notCompleted == MindOperationType.deleteAll) {
            EasyLoading.dismiss();
            showOkAlertDialog(
              context: context,
              title: 'Error',
              message: state.localizedString,
            );
          }
        case const (MindOperationCompleted):
          switch (state.type) {
            case MindOperationType.clearCache:
              EasyLoading.dismiss();
              setState(() {
                _clearCacheVisible = false;
              });
            case MindOperationType.deleteAll:
              EasyLoading.dismiss();
              sendEventTo<MindBloc>(SettingsGetMindCandidatesToUpload());
              showOkAlertDialog(
                context: context,
                title: 'Success',
                message: '`Your minds were completly deleted from server',
              );
          }
      }
    })?.disposed(by: this);

    sendEventTo<SettingsBloc>(SettingsGet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                    sendEventTo<SettingsBloc>(SettingsLogout());
                  },
                ),
            ],
          ),
          SettingsSection(
            title: Text('Appearance'.toUpperCase()),
            tiles: [
              SettingsTile.switchTile(
                initialValue: _isDarkMode,
                leading: const Icon(Icons.dark_mode, color: Colors.grey),
                title: const Text('Dark mode'),
                onToggle: (bool value) => _switchDarkMode(value),
              ),
              SettingsTile.switchTile(
                initialValue: _showTitles,
                leading: const Icon(Icons.title, color: Colors.grey),
                title: const Text('Show day dividers'),
                onToggle: (bool value) => _switchShowTitles(value),
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
                onToggle: (bool value) => _switchOfflineMode(value),
              ),
              if (_cachedMindCountToUpload > 0 && !_offlineMode && _isLoggedIn) ...{
                SettingsTile(
                  title: Text('Upload $_cachedMindCountToUpload minds'),
                  leading: const Icon(Icons.cloud_upload, color: Colors.green),
                  onPressed: (BuildContext context) {
                    sendEventTo<SettingsBloc>(SettingsUploadMindCandidates());
                  },
                ),
              },
              SettingsTile(
                title: const Text('Setup OpenAI Token'),
                leading: const Icon(Icons.chat, color: Colors.redAccent),
                onPressed: (BuildContext context) async {
                  await _showOpenAITokenChanger();
                },
              ),
              SettingsTile(
                title: const Text('Export to CSV'),
                leading: const Icon(Icons.file_download, color: Colors.brown),
                onPressed: (BuildContext context) {
                  // TODO: Add loading
                  sendEventTo<SettingsBloc>(SettingsExportAllMindsToCSV());
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('About'.toUpperCase()),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Suggest a feature'),
                leading: const Icon(Icons.handyman, color: Colors.yellow),
                onPressed: (BuildContext context) {
                  _openFeatureSuggestion();
                },
              ),
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
              SettingsTile.navigation(
                title: const Text('Source code'),
                leading: const Icon(Icons.code, color: Colors.grey),
                onPressed: (BuildContext context) async {
                  await _openSourceCode();
                },
              ),
            ],
          ),
          if (_isLoggedIn || _clearCacheVisible) ...{
            SettingsSection(
              title: Text('Danger zone'.toUpperCase()),
              tiles: [
                if (_isLoggedIn) ...{
                  SettingsTile(
                    title: const Text('Delete all data from server'),
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: (BuildContext context) async => await _deleteAllMindsFromServer(),
                  ),
                },
                if (_clearCacheVisible) ...{
                  SettingsTile(
                    title: const Text('Clear cache'),
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: (BuildContext context) async => await _clearCache(),
                  )
                },
                if (_isLoggedIn) ...{
                  SettingsTile(
                    title: const Text('Delete account'),
                    leading: const Icon(Icons.delete, color: Colors.red),
                    onPressed: (BuildContext context) async => await _deleteAccount(),
                  ),
                },
              ],
            )
          },
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: KeklistConstants.feedbackEmail,
      query: 'subject=Feedback about Keklist',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openSourceCode() async {
    final Uri uri = Uri.parse(KeklistConstants.sourceCodeURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openFeatureSuggestion() async {
    final Uri uri = Uri.parse(KeklistConstants.featureSuggestionURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showOpenAITokenChanger() async {
    String openAiToken = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Open AI Token'),
          content: TextField(
            onChanged: (value) => openAiToken = value,
            decoration: const InputDecoration(
              hintText: 'Enter token here',
              labelText: 'Token',
            ),
            controller: TextEditingController(text: _openAiKey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _openAiKey = openAiToken;
                Navigator.of(context).pop();
                sendEventTo<SettingsBloc>(SettingsChangeOpenAIKey(openAIToken: openAiToken));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final OkCancelResult result = await showOkCancelAlertDialog(
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

  void _switchOfflineMode(bool value) {
    sendEventTo<SettingsBloc>(SettingsChangeOfflineMode(isOfflineMode: value));
  }

  void _switchDarkMode(bool value) {
    sendEventTo<SettingsBloc>(SettingsChangeIsDarkMode(isDarkMode: value));
  }

  void _switchShowTitles(bool value) {
    sendEventTo<SettingsBloc>(SettingsUpdateShouldShowTitlesMode(value: value));
  }

  void _showWhatsNew() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => WebPageScreen(
          title: 'Whats new?',
          initialUri: Uri.parse(KeklistConstants.whatsNewURL),
        ),
      ),
    );
  }

  Future<void> _deleteAllMindsFromServer() async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: 'Are you sure?',
      message:
          'All your data will be deleted from server. Make sure that you have already exported it. Your offline minds will be saved only on your device.',
      cancelLabel: 'Cancel',
      okLabel: 'Delete all minds',
      isDestructiveAction: true,
    );
    switch (result) {
      case OkCancelResult.ok:
        sendEventTo<MindBloc>(MindDeleteAllMinds());
        break;
      case OkCancelResult.cancel:
        break;
    }
  }

  Future<void> _clearCache() async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      context: context,
      title: 'Are you sure?',
      message: 'All your offline data will be deleted. Make sure that you have already exported it.',
      cancelLabel: 'Cancel',
      okLabel: 'Clear cache',
      isDestructiveAction: true,
    );
    switch (result) {
      case OkCancelResult.ok:
        sendEventTo<MindBloc>(MindClearCache());
        break;
      case OkCancelResult.cancel:
        break;
    }
  }

  _showAuthBottomSheet() {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const AuthScreen(),
      isDismissible: false,
      enableDrag: false,
    );
  }
}
