import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keklist/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:keklist/presentation/blocs/mind_bloc/mind_bloc.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/screens/web_page/web_page_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: move methods from MindBloc to SettingsBloc
// TODO: fix bug with autologout after open it in offline mode
// TODO: darkmode: add system mode 

final class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

final class SettingsScreenState extends State<SettingsScreen> with DisposeBag {
  bool _isLoggedIn = false;
  bool _offlineMode = false;
  bool _isDarkMode = false;
  int _cachedMindCountToUpload = 0;
  bool _clearCacheVisible = false;
  String _openAiKey = '';

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(
      onNewState: (state) {
        switch (state.runtimeType) {
          case const (SettingsDataState):
            setState(() {
              _offlineMode = state.settings.isOfflineMode;
              _isDarkMode = state.settings.isDarkMode;
              _openAiKey = state.settings.openAIKey ?? '';
            });
        }
      },
    )?.disposed(by: this);

    subscribeTo<MindBloc>(onNewState: (state) {
      switch (state.runtimeType) {
        case const (MindList):
          setState(() {
            _clearCacheVisible = state.values.isNotEmpty;
          });
          if (!_offlineMode) {
            sendEventTo<MindBloc>(MindGetUploadCandidates());
          }
        case const (MindCandidatesForUpload):
          setState(() {
            if (_isLoggedIn && !_offlineMode) {
              _cachedMindCountToUpload = state.values.length;
            } else {
              _cachedMindCountToUpload = 0;
            }
          });
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
            case MindOperationType.uploadCachedData:
              EasyLoading.dismiss();
              setState(() {
                _cachedMindCountToUpload = 0;
              });
              showOkAlertDialog(
                context: context,
                title: 'Success',
                message: 'Minds have uploaded successfully',
              );
            case MindOperationType.deleteAll:
              EasyLoading.dismiss();
              sendEventTo<MindBloc>(MindGetUploadCandidates());
              showOkAlertDialog(
                context: context,
                title: 'Success',
                message: '`Your mind was cleared on server',
              );
          }
      }
    })?.disposed(by: this);

    subscribeTo<AuthBloc>(
      onNewState: (state) {
        setState(() {
          switch (state) {
            case AuthCurrentState state when state.isLoggedIn:
              _isLoggedIn = true;
              sendEventTo<MindBloc>(MindGetUploadCandidates());
            case AuthCurrentState state when !state.isLoggedIn:
              _isLoggedIn = false;
              if (!_offlineMode) {
                sendEventTo<SettingsBloc>(SettingsNeedToShowAuth());
              }
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
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 0,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
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
                    sendEventTo<SettingsBloc>(SettingsNeedToShowAuth());
                  },
                ),
              if (_isLoggedIn)
                SettingsTile(
                  title: const Text('Logout'),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onPressed: (BuildContext context) {
                    sendEventTo<AuthBloc>(AuthLogout());
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
              if (_cachedMindCountToUpload > 0 && !_offlineMode && _isLoggedIn) ...{
                SettingsTile(
                  title: Text('Upload $_cachedMindCountToUpload minds'),
                  leading: const Icon(Icons.cloud_upload, color: Colors.green),
                  onPressed: (BuildContext context) {
                    sendEventTo<MindBloc>(MindUploadCandidates());
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

  @override
  void dispose() {
    super.dispose();

    cancelSubscriptions();
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

  Future<void> _switchOfflineMode(bool value) async {
    sendEventTo<SettingsBloc>(SettingsChangeOfflineMode(isOfflineMode: value));
    if (!value) {
      sendEventTo<MindBloc>(MindGetList());
    }
  }

  Future<void> _switchDarkMode(bool value) async {
    sendEventTo<SettingsBloc>(SettingsChangeIsDarkMode(isDarkMode: value));
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
}
