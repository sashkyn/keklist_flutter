import 'dart:math';

enum KeklistErrorType {
  noAuthed(localizedMessage: 'Auth session has expired'),
  noConnection(localizedMessage: 'No internet connection'),
  dumbProtection(localizedMessage: 'Dumb protection'),
  randomError(localizedMessage: 'Random error description');

  final String localizedMessage;

  const KeklistErrorType({required this.localizedMessage});
}

class KeklistError extends Error {
  final KeklistErrorType type;

  KeklistError({required this.type});

  @override
  String toString() => 'KeklistError: $type, $type.message';

  factory KeklistError.nonAuthorized() => KeklistError(type: KeklistErrorType.noAuthed);
  factory KeklistError.noConnection() => KeklistError(type: KeklistErrorType.noConnection);
  factory KeklistError.dumbProtection() => KeklistError(type: KeklistErrorType.dumbProtection);
  factory KeklistError.randomError() {
    final random = Random();
    final randomIndex = random.nextInt(KeklistErrorType.values.length - 1);
    return KeklistError(type: KeklistErrorType.values[randomIndex]);
  }
}
