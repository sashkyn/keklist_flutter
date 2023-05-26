import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rememoji/blocs/settings_bloc/settings_bloc.dart';
import 'package:rememoji/helpers/bloc_utils.dart';
import 'package:rememoji/helpers/extensions/dispose_bag.dart';
import 'package:rememoji/screens/auth/auth_screen.dart';
import 'package:rememoji/screens/insights/insights_screen.dart';
import 'package:rememoji/screens/mind_collection/mind_collection_screen.dart';
import 'package:rememoji/screens/settings/settings_screen.dart';
import 'package:rememoji/widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with DisposeBag {
  bool _isAuthShowed = false;
  int _tabSelectedIndex = 0;

  static final List<Widget> _mainScreens = [
    const MindCollectionScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsAuthState && state.needToShowAuth) {
        _showAuthBottomSheet();
      }
    })?.disposed(by: this);
  }

  static const List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_emotions),
      label: 'Weeks',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.widgets),
      label: 'Insights',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabSelectedIndex, children: _mainScreens),
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _tabSelectedIndex,
        onTap: (index) {
          setState(() => _tabSelectedIndex = index);
        },
        items: _items,
      ),
    );
  }

  Future<void> _showAuthBottomSheet() async {
    if (_isAuthShowed) {
      return;
    }

    _isAuthShowed = true;
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const AuthScreen(),
      isDismissible: false,
      enableDrag: false,
    );
    _isAuthShowed = false;
  }
}
