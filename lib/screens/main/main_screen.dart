import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/helpers/bloc_utils.dart';
import 'package:keklist/helpers/extensions/dispose_bag.dart';
import 'package:keklist/screens/auth/auth_screen.dart';
import 'package:keklist/screens/insights/insights_screen.dart';
import 'package:keklist/screens/mind_collection/mind_collection_screen.dart';
import 'package:keklist/screens/settings/settings_screen.dart';
import 'package:keklist/widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with DisposeBag {
  bool _isAuthShowed = false;
  int _tabSelectedIndex = 0;

  static final List<Widget> _mainScreens = [
    const SizedBox(
      width: 1000,
      height: 1000,
      child: MindCollectionScreen(),
    ),
    const SizedBox(
      width: 1000,
      height: 1000,
      child: InsightsScreen(),
    ),
    const SizedBox(
      width: 1000,
      height: 1000,
      child: SettingsScreen(),
    ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 && constraints.maxHeight > 600) {
          // iPad layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  destinations: _mainScreens.map((screen) {
                    final int index = _mainScreens.indexOf(screen);
                    return NavigationRailDestination(
                      icon: _items[index].icon,
                      label: Text(_items[index].label!),
                    );
                  }).toList(),
                  selectedIndex: _tabSelectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _tabSelectedIndex = index);
                  },
                ),
                const VerticalDivider(thickness: 1, width: 1),
                IndexedStack(index: _tabSelectedIndex, children: _mainScreens)
              ],
            ),
          );
        } else {
          // Phone layout
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
      },
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
