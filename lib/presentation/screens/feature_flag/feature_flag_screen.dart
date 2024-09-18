import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

final class FeatureFlagScreen extends StatefulWidget {
  const FeatureFlagScreen({super.key});

  @override
  State<FeatureFlagScreen> createState() => _FeatureFlagScreenState();
}

final class _FeatureFlagScreenState extends State<FeatureFlagScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature flags')),
      body: SettingsList(sections: [
        SettingsSection(tiles: [
          SettingsTile.switchTile(
            title: const Text('Chat with AI'),
            description: const Text('Showing/Hiding Chat with AI action, that allows to discuss Mind with AI in chat.'),
            onToggle: (bool value) {},
            initialValue: false,
          ),
          SettingsTile.switchTile(
            title: const Text('Tranlsate content'),
            description:
                const Text('Showing/Hiding Translate action, that just opens Alert with translation on English.'),
            onToggle: (bool value) {},
            initialValue: false,
          ),
          SettingsTile.switchTile(
            title: const Text('Sensitive content'),
            description: const Text(
                'Showing/Hiding Eye button that allows to hide content for users when you showing phone to others.'),
            onToggle: (bool value) {},
            initialValue: false,
          ),
        ]),
      ]),
    );
  }
}
