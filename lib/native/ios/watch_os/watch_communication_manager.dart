// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:zenmode/helpers/extensions/enum_from_string.dart';
import 'package:zenmode/helpers/mind_utils.dart';
import 'package:zenmode/services/entities/mind.dart';
import 'package:zenmode/services/main_service.dart';

abstract class WatchCommunicationManager {
  void connect() {}
}

class AppleWatchCommunicationManager implements WatchCommunicationManager {
  final _channel = const MethodChannel('com.sashkyn.kekable');

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
    await _channel.invokeMethod(
      methodName,
      [methodArguments],
    );
  }

  void _setupCallBackHandler() {
    _channel.setMethodCallHandler(
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
        } else if (methodName == stringFromEnum(WatchInputMethod.createMind)) {
          final mindText = methodArgs[stringFromEnum(WatchMethodArgumentKey.mindText)];
          final emoji = methodArgs[stringFromEnum(WatchMethodArgumentKey.mindEmoji)];
          return _createMindForToday(
            mindText: mindText,
            emoji: emoji,
          );
        } else if (methodName == stringFromEnum(WatchInputMethod.deleteMind)) {
          final mindId = methodArgs[stringFromEnum(WatchMethodArgumentKey.mindID)];
          return _removeMindFromToday(id: mindId);
        }
      },
    );
  }

  Future<void> _createMindForToday({
    required String mindText,
    required String emoji,
  }) async {
    final dayIndex = MindUtils.getDayIndex(from: DateTime.now());
    final mindList = await mainService.getMindList();
    final sortIndex = mindList.where((element) => element.dayIndex == dayIndex).length;

    final mind = Mind(
      id: const Uuid().v4(),
      dayIndex: MindUtils.getDayIndex(from: DateTime.now()),
      note: mindText,
      emoji: emoji,
      creationDate: DateTime.now().millisecondsSinceEpoch,
      sortIndex: sortIndex,
    );
    await mainService.addMind(mind);
    final mindJSON = json.encode(
      mind,
      toEncodable: (_) => mind.toWatchJson(),
    );
    return _sendToWatch(
      output: WatchOutputMethod.mindDidCreated,
      arguments: {
        WatchMethodArgumentKey.mind: mindJSON,
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

  Future<void> _removeMindFromToday({required String id}) async {
    await mainService.removeMind(id);
    return _sendToWatch(
      output: WatchOutputMethod.mindDidDeleted,
      arguments: {},
    );
  }

  Future<void> _displayPredictedEmojies({required String mindText}) async {
    // TODO: сделать релевантным введенному тексту с часов
    final mindList = await mainService.getMindList();
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
  createMind,
  deleteMind,
}

enum WatchOutputMethod {
  displayMinds,
  displayPredictedEmojies,
  displayError,
  showLoading,
  mindDidCreated,
  mindDidDeleted,
}

enum WatchMethodArgumentKey {
  minds,
  mind,
  mindId,
  mindText,
  mindEmoji,
  emojies,
  mindID,
}
