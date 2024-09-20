import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_pie_widget.dart';
import 'package:keklist/presentation/screens/settings/settings_screen.dart';

final class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

final class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettings();
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(16.0),
          const CircleAvatar(
            radius: 80.0,
            backgroundColor: Colors.blueAccent,
          ),
          const Gap(16.0),
          const Text(
            "@sashkyn",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(16.0),
          const Text(
            "I am",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          // TODO: make it wrapable and suggestable
          Row(
            children: [
              MyChip(
                isSelected: false,
                onSelect: (_) => print('didSelect'),
                selectedColor: Colors.white,
                child: const Text(
                  '✊ Сильный',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              MyChip(
                isSelected: false,
                onSelect: (_) => print('didSelect'),
                selectedColor: Colors.white,
                child: const Text(
                  '🏀 Баскетболист',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              MyChip(
                isSelected: false,
                onSelect: (_) => print('didSelect'),
                selectedColor: Colors.white,
                child: const Text(
                  ' Релизер',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
