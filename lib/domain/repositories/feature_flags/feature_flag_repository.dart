import 'dart:async';

abstract class FeatureFlagRepository {
  List<FeatureFlagData> get value;
  Stream<List<FeatureFlagData>> get stream;
  FutureOr<void> update({FeatureFlagType flagType, bool value});
}

final class FeatureFlagData {
  final FeatureFlagType type;
  final bool value;

  FeatureFlagData({
    required this.type,
    required this.value,
  });
}

enum FeatureFlagType {
  chatWithAI,
  translation,
  sensitiveContent,
}
