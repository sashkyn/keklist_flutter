import 'package:hive_flutter/hive_flutter.dart';
import 'package:keklist/domain/repositories/feature_flags/feature_flag_repository.dart';
import 'package:keklist/presentation/core/enum_from_string.dart';

part 'feature_flag_object.g.dart';

@HiveType(typeId: 0)
final class FeatureFlagObject extends HiveObject {
  @HiveField(0, defaultValue: null)
  late String flagType;

  @HiveField(1, defaultValue: true)
  late bool value;

  FeatureFlagData? toFeatureFlagData() {
    final FeatureFlagType? featureFlagType = enumFromString(
      value: flagType,
      fromValues: FeatureFlagType.values,
    );
    if (featureFlagType == null) return null;
    return FeatureFlagData(
      type: featureFlagType,
      value: value,
    );
  }
}
