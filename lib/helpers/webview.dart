import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void openUrl(String url, BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => WebViewScaffold(url: url)));
}

class WebViewScaffold extends StatefulWidget {

  final String url;
  const WebViewScaffold({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewScaffoldState createState() => _WebViewScaffoldState();
}

class _WebViewScaffoldState extends State<WebViewScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.url,
      ),
    );
  }
}
