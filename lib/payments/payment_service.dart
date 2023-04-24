import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class PaymentService {
  /// To listen the status of connection between app and the billing server
  StreamSubscription<ConnectionResult>? _connectionSubscription;

  /// To listen the status of the purchase made inside or outside of the app (App Store / Play Store)
  ///
  /// If status is not error then app will be notied by this stream
  StreamSubscription<PurchasedItem?>? _purchaseUpdatedSubscription;

  /// To listen the errors of the purchase
  StreamSubscription<PurchaseResult?>? _purchaseErrorSubscription;

  /// List of product ids you want to fetch
  final List<String> _productIds = [
    'com.sashkyn.keklist.pro',
  ];

  /// All available products will be store in this list
  final List<IAPItem> _products = [];

  /// All past purchases will be store in this list
  final List<PurchasedItem> _pastPurchases = [];

  /// view of the app will subscribe to this to get notified
  /// when premium status of the user changes
  final ObserverList<Function> _premiumStatusChangedListeners = ObserverList<Function>();

  /// view of the app will subscribe to this to get errors of the purchase
  final ObserverList<Function(String)> _errorListeners = ObserverList<Function(String)>();

  /// logged in user's premium status
  bool _isPremiumUser = false;

  bool get isPremiumUser => _isPremiumUser;

  /// Call this method at the startup of you app to initialize connection
  /// with billing server and get all the necessary data
  void initConnection() async {
    await FlutterInappPurchase.instance.initialize();
    _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {});
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);
    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen(_handlePurchaseError);

    _getItems();
    _getPastPurchases();
  }

  /// view can subscribe to _premiumStatusChangedListeners using this method
  void addToPremiumStatusChangedListeners(Function callback) {
    _premiumStatusChangedListeners.add(callback);
  }

  /// view can cancel to _premiumStatusChangedListeners using this method
  void removeFromPremuimStatusChangedListeners(Function callback) {
    _premiumStatusChangedListeners.remove(callback);
  }

  /// view can subscribe to _errorListeners using this method
  void addToErrorListeners(Function(String) callback) {
    _errorListeners.add(callback);
  }

  /// view can cancel to _errorListeners using this method
  void removeFromErrorListeners(Function(String) callback) {
    _errorListeners.remove(callback);
  }

  /// Call this method to notify all the subsctibers of _premiumStatusChangedListeners
  void _callPremiumStatusChangedListeners() {
    for (final callback in _premiumStatusChangedListeners) {
      callback();
    }
  }

  /// Call this method to notify all the subscribers of _errorListeners
  void _callErrorListeners(String error) {
    for (final callback in _errorListeners) {
      callback(error);
    }
  }

  void _handlePurchaseError(PurchaseResult? purchaseError) {
    if (purchaseError == null && purchaseError?.message == null) {
      return;
    }
    _callErrorListeners(purchaseError!.message!);
  }

  /// Called when new updates arrives at ``purchaseUpdated`` stream
  void _handlePurchaseUpdate(PurchasedItem? productItem) async {
    if (productItem == null) {
      return;
    }

    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(productItem);
    } else {
      await _handlePurchaseUpdateIOS(productItem);
    }
  }

  Future<void> _handlePurchaseUpdateIOS(PurchasedItem purchasedItem) async {
    switch (purchasedItem.transactionStateIOS) {
      case TransactionState.deferred:
        // Edit: This was a bug that was pointed out here : https://github.com/dooboolab/flutter_inapp_purchase/issues/234
        // FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      case TransactionState.failed:
        _callErrorListeners("Transaction Failed");
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      case TransactionState.purchased:
        await _verifyAndFinishTransaction(purchasedItem);
        break;
      case TransactionState.purchasing:
        break;
      case TransactionState.restored:
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      default:
    }
  }

  Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
    switch (purchasedItem.purchaseStateAndroid) {
      case PurchaseState.purchased:
        if (purchasedItem.isAcknowledgedAndroid != null && !purchasedItem.isAcknowledgedAndroid!) {
          await _verifyAndFinishTransaction(purchasedItem);
        }
        break;
      default:
        _callErrorListeners("Something went wrong");
    }
  }

  /// Call this method when status of purchase is success
  /// Call API of your back end to verify the reciept
  /// back end has to call billing server's API to verify the purchase token
  Future<void> _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    bool isValid = false;

    // Call API
    isValid = await _verifyPurchase(purchasedItem);

    // При ошибках вызвать _callErrorListeners(error) и return

    if (isValid) {
      FlutterInappPurchase.instance.finishTransaction(purchasedItem);
      _isPremiumUser = true;
      // save in sharedPreference here
      _callPremiumStatusChangedListeners();
    } else {
      _callErrorListeners("Varification failed");
    }
  }

  Future<List<IAPItem>> get products async {
    if (_products.isEmpty) {
      await _getItems();
    }
    return _products;
  }

  Future<void> _getItems() async {
    final List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(_productIds);

    _products.clear();
    for (var item in items) {
      _products.add(item);
    }
  }

  // TODO: implement edge function on Supabase.
  Future<bool> _verifyPurchase(PurchasedItem purchasedItem) {
    return Future.value(true);
  }

  /// If you have noticed that in initConnection we are calling the _getPastPurchases() method.
  ///
  /// In iOS, this method returns all the purchases made in past(only finished).
  /// Another use of this method in iOS is when the user changes the device and you want to allow the user to restore
  /// his/her purchases then call this method.
  ///
  /// In Android, this method returns only active subscriptions (finished & unfinished both).
  void _getPastPurchases() async {
    // remove this if you want to restore past purchases in iOS
    if (Platform.isIOS) {
      return;
    }
    final List<PurchasedItem> purchasedItems = await FlutterInappPurchase.instance.getAvailablePurchases() ?? [];

    for (var purchasedItem in purchasedItems) {
      bool isValid = false;

      if (Platform.isAndroid) {
        if (purchasedItem.transactionReceipt == null) {
          return;
        }

        final Map<String, dynamic> receiptJSON = json.decode(purchasedItem.transactionReceipt!);
        // if your app missed finishTransaction due to network or crash issue
        // finish transactins
        if (!receiptJSON['acknowledged']) {
          isValid = await _verifyPurchase(purchasedItem);
          if (isValid) {
            FlutterInappPurchase.instance.finishTransaction(purchasedItem);
            _isPremiumUser = true;
            _callPremiumStatusChangedListeners();
          }
        } else {
          _isPremiumUser = true;
          _callPremiumStatusChangedListeners();
        }
      }
    }

    _pastPurchases
      ..clear()
      ..addAll(purchasedItems);
  }

  Future<void> buyProduct(IAPItem item) async {
    try {
      if (item.productId == null) {
        // TODO: throw error
        return;
      }
      await FlutterInappPurchase.instance.requestSubscription(item.productId!);
    } catch (error) {
      // TODO: throw error
    }
  }

  /// call when user close the app
  Future<void> dispose() async {
    _connectionSubscription?.cancel();
    _purchaseErrorSubscription?.cancel();
    _purchaseUpdatedSubscription?.cancel();
    await FlutterInappPurchase.instance.finalize();
  }
}
