// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:zenmode/helpers/extensions/enum_from_string.dart';
import 'package:zenmode/helpers/mind_utils.dart';
import 'package:zenmode/services/main_service.dart';

// TODO: сделать парсинг моделей в iOS приложении а затем кидать результат в часы
// TODO: отобразить список эмодзи на экране
// TODO: сделать создание и удаление эмодзи

abstract class WatchCommunicationManager {
  void connect() {}
}

class AppleWatchCommunicationManager implements WatchCommunicationManager {
  final channel = const MethodChannel('com.sashkyn.kekable');

  final MainService mainService;

  AppleWatchCommunicationManager({required this.mainService});

  @override
  void connect() {
    _setupCallBackHandler();
  }

  Future<void> _sendToWatch({
    required WatchOutputMethod output,
    required Map<WatchMethodArgumentKey, dynamic> arguments,
  }) async {
    final Map<String, String> methodArguments = arguments.map(
      (key, value) => MapEntry<String, String>(
        stringFromEnum(key.toString()),
        value.toString(),
      ),
    );

    final methodName = stringFromEnum(output);
    await channel.invokeMethod(
      methodName,
      [methodArguments],
    );
  }

  void _setupCallBackHandler() {
    channel.setMethodCallHandler(
      (MethodCall call) async {
        final String methodName = call.method;
        final methodArgs = call.arguments;

        print('methodName = $methodName');
        print('methodArgs = $methodArgs');

        if (methodName == stringFromEnum(WatchInputMethod.obtainTodayMinds)) {
          return _displayMindList();
        } else if (methodName == stringFromEnum(WatchInputMethod.obtainPredictedEmojies)) {
          final mindText = methodArgs[stringFromEnum(WatchMethodArgumentKey.mindText)];
          return _displayPredictedEmojies(mindText: mindText);
        } else if (methodName == WatchInputMethod.createNewMind.toString()) {
          // TODO: сделать создание mind-а и отправить все на часы
        } else if (methodName == WatchInputMethod.deleteMind.toString()) {
          // TODO: сделать удаление mind-а и отправить все на часы
        }
        // TODO: возвращать на каждый кейс свою Future
        return Future.value();
      },
    );
  }

  Future<void> _displayMindList() async {
    final mindList = await mainService.getMindList();
    final todayMindList = mindList
        .where(
          (element) => element.dayIndex == MindUtils.getDayIndex(from: DateTime.now()),
        )
        .toList();
    final List<String> mindJSONList = todayMindList
        .map(
          (mind) => json.encode(
            mind,
            toEncodable: (i) => mind.toWatchJson(),
          ),
        )
        .toList();
    return _sendToWatch(
      output: WatchOutputMethod.displayMinds,
      arguments: {
        WatchMethodArgumentKey.minds: mindJSONList,
      },
    );
  }

  Future<void> _displayPredictedEmojies({required String mindText}) async {
    // TODO: сделать релевантным введенному тексту с часов

    final mindList = await mainService.getMindList();

    // TODO: отсортировать по частоте
    final predictedEmojies = mindList.map((e) => e.emoji).toSet();

    final List<String> emojiJSONList = predictedEmojies.map((mind) => json.encode(mind)).toList();

    return _sendToWatch(
      output: WatchOutputMethod.displayPredictedEmojies,
      arguments: {
        WatchMethodArgumentKey.emojies: emojiJSONList,
      },
    );
  }
}

enum WatchInputMethod {
  obtainTodayMinds,
  obtainPredictedEmojies,
  createNewMind,
  deleteMind,
}

enum WatchOutputMethod {
  displayMinds,
  displayPredictedEmojies,
  displayError,
  showLoading,
}

enum WatchMethodArgumentKey {
  minds,
  mind,
  mindId,
  mindText,
  emojies,
}
