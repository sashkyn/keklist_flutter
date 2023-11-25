import 'package:flutter/material.dart';
import 'package:keklist/widgets/bool_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

// TODO: добавить обработку ошибок

class WebPageScreen extends StatefulWidget {
  final String title;
  final Uri initialUri;

  const WebPageScreen({
    super.key,
    required this.initialUri,
    required this.title,
  });

  @override
  State<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<WebPageScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: BoolWidget(
        condition: _isLoading,
        trueChild: const LinearProgressIndicator(),
        falseChild: WebViewWidget(
          controller: WebViewController()
            ..loadRequest(widget.initialUri)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (uri) {
                  if (!_isLoading) {
                    return;
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ),
        ),
      ),
    );
  }
}
