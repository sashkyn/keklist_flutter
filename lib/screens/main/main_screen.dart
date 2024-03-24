import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:keklist/core/widgets/bool_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:keklist/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/core/helpers/bloc_utils.dart';
import 'package:keklist/core/dispose_bag.dart';
import 'package:keklist/screens/auth/auth_screen.dart';
import 'package:keklist/screens/insights/insights_screen.dart';
import 'package:keklist/screens/mind_collection/mind_collection_screen.dart';
import 'package:keklist/screens/settings/settings_screen.dart';
import 'package:keklist/core/widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with DisposeBag {
  bool _isAuthShowed = false;
  int _tabSelectedIndex = 0;

  static final List<Widget> _mainScreens = [
    const InsightsScreen(),
    const MindCollectionScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(onNewState: (state) {
      if (state is SettingsAuthState && state.needToShowAuth) {
        setState(() => _tabSelectedIndex = 1);
        _showAuthBottomSheet();
      }
    })?.disposed(by: this);
  }

  static const List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_rounded),
      label: 'Calendar',
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
        if (constraints.maxWidth > 600) {
          // iPad layout
          return Scaffold(
            body: Row(
              children: [
                BoolWidget(
                  condition: !_isAuthShowed,
                  trueChild: NavigationRail(
                    destinations: _items.mapIndexed(
                      (index, item) {
                        return NavigationRailDestination(
                          icon: Icon(
                            (item.icon as Icon).icon,
                            color: _tabSelectedIndex == index ? Theme.of(context).scaffoldBackgroundColor : null,
                          ),
                          label: Text(item.label!),
                        );
                      },
                    ).toList(),
                    selectedIndex: _tabSelectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _tabSelectedIndex = index);
                    },
                  ),
                  falseChild: const SizedBox.shrink(),
                ),
                BoolWidget(
                  condition: !_isAuthShowed,
                  trueChild: const VerticalDivider(
                    thickness: 1.0,
                    width: 0.2,
                  ),
                  falseChild: const SizedBox.shrink(),
                ),
                Flexible(
                  child: IndexedStack(
                    index: _tabSelectedIndex,
                    children: _mainScreens,
                  ),
                )
              ],
            ),
          );
        } else {
          // Phone layout
          return Scaffold(
            body: IndexedStack(
              index: _tabSelectedIndex,
              children: _mainScreens,
            ),
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
