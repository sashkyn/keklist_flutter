import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/screens/auth/auth_screen.dart';
import 'package:keklist/presentation/screens/mind_collection/mind_collection_screen.dart';

final class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

final class _MainScreenState extends KekWidgetState<MainScreen> {
  bool _isAuthShowed = false;

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsAuthState && state.needToShowAuth) {
        _showAuthBottomSheet();
      }
    })?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) => const MindCollectionScreen();

  Future<void> _showAuthBottomSheet() async {
    if (_isAuthShowed) {
      return;
    }

    setState(() => _isAuthShowed = true);
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const AuthScreen(),
      isDismissible: false,
      enableDrag: false,
    );
    setState(() => _isAuthShowed = false);
  }
}
