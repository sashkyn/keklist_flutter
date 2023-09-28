import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const AdaptiveBottomNavigationBar({
    super.key,
    required this.onTap,
    required this.selectedIndex,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isAndroid) {
      return BottomNavigationBar(
        items: items,
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: onTap,
      );
    } else if (Platform.isIOS) {
      return CupertinoTabBar(
        items: items,
        currentIndex: selectedIndex,
        activeColor: Colors.black,
        onTap: onTap,
      );
    } else {
      return BottomNavigationBar(
        items: items,
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: onTap,
      );
    }
  }
}
