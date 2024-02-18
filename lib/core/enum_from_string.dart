import 'package:collection/collection.dart';

T? enumFromString<T>({
  required String? value,
  required Iterable<T> fromValues,
}) {
  return fromValues.firstWhereOrNull((type) => stringFromEnum(type) == value);
}

String stringFromEnum<T>(T value) {
  return value.toString().split(".").last;
}
