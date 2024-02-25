import 'package:dart_openai/dart_openai.dart';
import 'package:keklist/services/entities/message.dart';
import 'package:keklist/services/entities/mind.dart';
import 'package:uuid/uuid.dart';

abstract class MessageService {
  Future<MessageHistory> initializeDiscussion({
    required Mind rootMind,
    required List<Mind> rootMindChildren,
    required String initMessageText,
  });
  Future<Message> requestAnswer({required MessageHistory history});
}

final class MessageHistory {
  final String rootMindId;
  final List<Message> messages;

  MessageHistory({
    required this.messages,
    required this.rootMindId,
  });
}

final class MessageOpenAIService implements MessageService {
  @override
  Future<MessageHistory> initializeDiscussion({
    required Mind rootMind,
    required List<Mind> rootMindChildren,
    required String initMessageText,
  }) async {
    final Message initMessage = Message(
      id: const Uuid().v4(),
      text: initMessageText,
      rootMindId: rootMind.id,
      timestamp: DateTime.now(),
      sender: MessageSender.system,
    );
    final initMessageModel = OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(initMessageText)],
      role: OpenAIChatMessageRole.system,
    );
    final requestMessages = [initMessageModel];

    final Message openAIAnswerMessage = await _obtainChatAnswerMessage(requestMessages, rootMind.id);
    return MessageHistory(
      messages: [
        initMessage,
        openAIAnswerMessage,
      ],
      rootMindId: rootMind.id,
    );
  }

  @override
  Future<Message> requestAnswer({required MessageHistory history}) {
    final List<OpenAIChatCompletionChoiceMessageModel> requestMessages =
        mapMessagesToOpenAIChatCompletionChoiceMessageModel(history.messages);
    return _obtainChatAnswerMessage(requestMessages, history.rootMindId);
  }

  List<OpenAIChatCompletionChoiceMessageModel> mapMessagesToOpenAIChatCompletionChoiceMessageModel(
    List<Message> messages,
  ) =>
      messages
          .map(
            (message) => OpenAIChatCompletionChoiceMessageModel(
              content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(message.text)],
              role: _mapMessageSenderToOpenAIChatMessageRole(message.sender),
            ),
          )
          .toList();

  OpenAIChatMessageRole _mapMessageSenderToOpenAIChatMessageRole(MessageSender sender) {
    switch (sender) {
      case MessageSender.assistant:
        return OpenAIChatMessageRole.assistant;
      case MessageSender.system:
        return OpenAIChatMessageRole.system;
      case MessageSender.user:
        return OpenAIChatMessageRole.user;
    }
  }

  Future<Message> _obtainChatAnswerMessage(
    List<OpenAIChatCompletionChoiceMessageModel> requestMessages,
    String rootMindId,
  ) async {
    final OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      // model: "gpt-3.5-turbo-1106",
      model: 'gpt-4-0125-preview',
      n: 1,
      seed: 6,
      messages: requestMessages,
      temperature: 0.2, // 0.2 determined, 0.8 more random, 2.0 very random
      maxTokens: 256,
    );
    if (chatCompletion.choices.isEmpty) {
      throw Exception('There are no chat completion choices!');
    }
    final OpenAIChatCompletionChoiceModel firstChoice = chatCompletion.choices.first;
    if (firstChoice.message.content == null) {
      throw Exception('There are no chat completion choices!');
    }
    final OpenAIChatCompletionChoiceMessageContentItemModel? firstChoiceContent = firstChoice.message.content?.first;
    if (firstChoiceContent == null) {
      throw Exception('There are no chat completion choices!');
    }
    final String? psycologistMessageText = firstChoiceContent.text;
    if (psycologistMessageText == null || psycologistMessageText.isEmpty) {
      throw Exception('There is no message!');
    }
    final Message openAIAnswerMessage = Message(
      id: const Uuid().v4(),
      text: psycologistMessageText,
      rootMindId: rootMindId,
      timestamp: DateTime.now(),
      sender: MessageSender.assistant,
    );
    return openAIAnswerMessage;
  }
}
