import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';

class WebViewContainer extends StatefulWidget {
  final String url;
  WebViewContainer(this.url);
  @override
  State<WebViewContainer> createState() => _WebViewContainerState(this.url);
}

class _WebViewContainerState extends State<WebViewContainer> {
  late final WebViewController controller;
  String _url;

  _WebViewContainerState(this._url);

  @override
  void initState() {
    super.initState();
    // construct body payload
    // final body = jsonEncode({
    //   "email": "asd@gmail.com",
    //   "password": "1234567",
    // });

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        method: LoadRequestMethod.get,
        Uri.parse(_url),
        // body: convertStringToUint8List(body),
        // body: Uint8List.fromList(utf8.encode('input_data=$body')),
        // headers: {
        //   'Content-Type': 'application/x-www-form-urlencoded',
        // },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tulibot Webview"),
        ),
        body: WebViewWidget(controller: controller));
  }
}

Uint8List convertStringToUint8List(String str) {
  final List<int> codeUnits = str.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  return unit8List;
}
