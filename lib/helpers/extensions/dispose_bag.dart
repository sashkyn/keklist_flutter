import 'dart:async';

mixin DisposeBag {
  final List<StreamSubscription> _subscriptions = [];

  void cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  void _addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
}

extension Disposable on StreamSubscription {
  void disposed({required DisposeBag by}) {
    by._addSubscription(this);
  }
}
