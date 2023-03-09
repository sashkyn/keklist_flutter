// ignore_for_file: avoid_print

import 'dart:convert';

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
          final mindList = await mainService.getMindList();
          final todayMindList = mindList
              .where(
                (element) => element.dayIndex == MindUtils.getDayIndex(from: DateTime.now()),
              )
              .toList();
          // final mindJSONList = todayMindList.map((item) => item.toWatchJson()).toList();

          final List<String> mindJSONList = todayMindList.map((e) {
            return json.encode(
              e,
              toEncodable: (i) => e.toWatchJson(),
            );
          }).toList();
          _sendToWatch(
            output: WatchOutputMethod.displayMinds,
            arguments: {
              WatchMethodArgumentKey.minds: mindJSONList,
            },
          );
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
}

enum WatchInputMethod {
  obtainTodayMinds,
  createNewMind,
  deleteMind,
}

enum WatchOutputMethod {
  displayMinds,
  displayError,
  showLoading,
}

enum WatchMethodArgumentKey {
  minds,
  mind,
  mindId,
}
