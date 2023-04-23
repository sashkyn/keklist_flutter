import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPageScreen extends StatelessWidget {
  final String title;
  final Uri initialUri;

  const WebPageScreen({
    super.key,
    required this.initialUri,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: WebViewWidget(
        controller: WebViewController()..loadRequest(initialUri),
      ),
    );
  }
}
