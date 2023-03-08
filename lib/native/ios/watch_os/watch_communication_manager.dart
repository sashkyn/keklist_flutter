// ignore_for_file: avoid_print

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
    required _WatchOutputMethod output,
    required Map<_WatchMethodArgumentKey, dynamic> arguments,
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

        if (methodName == stringFromEnum(_WatchInputMethod.obtainTodayMinds)) {
          _sendToWatch(
            output: _WatchOutputMethod.showLoading,
            arguments: {},
          );
          final mindList = await mainService.getMindList();
          final todayMindList = mindList.where(
            (element) => element.dayIndex == MindUtils.getDayIndex(from: DateTime.now()),
          );
          _sendToWatch(
            output: _WatchOutputMethod.displayMinds,
            arguments: {
              _WatchMethodArgumentKey.minds: todayMindList.map((e) => e.toWatchJson()),
            },
          );
        } else if (methodName == _WatchInputMethod.createNewMind.toString()) {
          // TODO: сделать создание mind-а и отправить все на часы
        } else if (methodName == _WatchInputMethod.deleteMind.toString()) {
          // TODO: сделать удаление mind-а и отправить все на часы
        }
        // TODO: возвращать на каждый кейс свою Future
        return Future.value();
      },
    );
  }
}

enum _WatchInputMethod {
  obtainTodayMinds,
  createNewMind,
  deleteMind,
}

enum _WatchOutputMethod {
  displayMinds,
  displayError,
  showLoading,
}

enum _WatchMethodArgumentKey {
  minds,
  mind,
  mindId,
}
