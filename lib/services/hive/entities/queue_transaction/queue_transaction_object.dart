import 'package:hive/hive.dart';

part 'queue_transaction_object.g.dart';

@HiveType(typeId: 2)
final class QueueTransactionObject {
  @HiveField(0)
  final Future<dynamic> transaction;

  @HiveField(1)
  final String debugName;

  QueueTransactionObject({
    required this.transaction,
    required this.debugName,
  });
}
