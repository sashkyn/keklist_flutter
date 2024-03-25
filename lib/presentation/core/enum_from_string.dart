import 'package:collection/collection.dart';

T? enumFromString<T>({
  required String? value,
  required Iterable<T> fromValues,
}) => fromValues.firstWhereOrNull((type) => stringFromEnum(type) == value);

String stringFromEnum<T>(T value) => value.toString().split(".").last;
