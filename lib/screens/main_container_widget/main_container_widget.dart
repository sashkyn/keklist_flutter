import 'package:flutter/material.dart';
import 'package:rememoji/screens/mind_collection/mind_collection_screen.dart';
import 'package:rememoji/screens/settings/settings_screen.dart';
import 'package:rememoji/widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _bodyWidgets = [
    const MindCollectionScreen(),
    Container(color: Colors.white),
    const SettingsScreen(),
  ];

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
      body: _bodyWidgets[_selectedIndex],
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: _items,
      ),
    );
  }
}
