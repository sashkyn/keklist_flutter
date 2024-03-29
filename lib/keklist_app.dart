import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/domain/constants.dart';
import 'package:keklist/presentation/core/helpers/bloc_utils.dart';
import 'package:keklist/presentation/core/dispose_bag.dart';
import 'package:keklist/presentation/core/screen/kek_screen_state.dart';
import 'package:keklist/presentation/screens/main/main_screen.dart';

final class KeklistApp extends StatefulWidget {
  const KeklistApp({super.key});

  @override
  State<KeklistApp> createState() => KeklistAppState();
}

final class KeklistAppState extends KekWidgetState<KeklistApp> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();

    subscribeTo<SettingsBloc>(
      onNewState: (state) {
        if (state is SettingsDataState) {
          if (state.openAIKey != null) {
            OpenAI.apiKey = state.openAIKey!;
          }
          setState(() => _isDarkMode = state.isDarkMode);
        }
      },
    )?.disposed(by: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keklist',
      home: const MainScreen(),
      theme: _isDarkMode ? Themes.dark : Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeMode.light,
      builder: EasyLoading.init(),
    );
  }
}
