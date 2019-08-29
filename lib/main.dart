import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:async';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutterdemo/UploadFile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

var url = "http://192.168.0.173/facebook.html";

BuildContext _context;
final flutterWebviewPlugin = new FlutterWebviewPlugin();

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Android',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
        initiateFacebookLogin();
        /*Navigator
            .of(_context)
            .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => UploadFile()));*/
      }),
].toSet();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewContainer1(url),
    );
  }
}

class WebViewContainer1 extends StatefulWidget {
  final url;

  WebViewContainer1(this.url);

  @override
  createState() => _WebViewContainerState1(this.url);
}

class _WebViewContainerState1 extends State<WebViewContainer1> {
  var _url;
  final _key = UniqueKey();

  _WebViewContainerState1(this._url);


  StreamSubscription<WebViewStateChanged> _onchanged;

  @override
  void initState() {
    super.initState();
    _onchanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        if (state.type == WebViewState.finishLoad) {
          // if the full website page loaded
          print("loaded...");/*
          url = "javascript:onDocFetchComplete(200)";
          flutterWebviewPlugin.evalJavascript(url);*/
        } else if (state.type == WebViewState.abortLoad) {
          // if there is a problem with loading the url
          print("there is a problem...");
        } else if (state.type == WebViewState.startLoad) {
          // if the url started loading
          print("start loading...");
        }
      }
    });

    @override
    void dispose() {
      super.dispose();
      flutterWebviewPlugin.dispose(); // disposing the webview widget
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return WebviewScaffold(
      url: this._url,
      withJavascript: true,
      debuggingEnabled: true,
      useWideViewPort: true,
      withOverviewMode: true,
      supportMultipleWindows: true,
      allowFileURLs: true,
      enableAppScheme: true,
      javascriptChannels: jsChannels,
      hidden: true,
    );
  }
}

void initiateFacebookLogin() async {
  var facebookLogin = FacebookLogin();
  var facebookLoginResult =
  await facebookLogin.logInWithReadPermissions(['email']);
  final token = facebookLoginResult.accessToken.token;
  final graphResponse = await http.get(
      'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
  //final profile = JSON.decode(graphResponse.body);
  AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: token);
  final Future<AuthResult> user = FirebaseAuth.instance.signInWithCredential(credential);
  user.then((AuthResult result) {
    print("FacebookUserAuth ${result.user.displayName} : ${result.user.email} : ${result.user.phoneNumber}");
    String value = "Name: ${result.user.displayName} , Email: ${result.user.email}";
    url = "javascript:onDocFetchComplete('$value')";
    //flutterWebviewPlugin.evalJavascript(url);
    _showToast(value);
    Navigator
        .of(_context)
        .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => UploadFile()));
    //_showToast(_context, "${result.user.displayName} : ${result.user.email} : ${result.user.phoneNumber}");
  });
  print(graphResponse.body);
  switch (facebookLoginResult.status) {
    case FacebookLoginStatus.error:
      print("Error");
      break;
    case FacebookLoginStatus.cancelledByUser:
      print("CancelledByUser");
      break;
    case FacebookLoginStatus.loggedIn:
      print("LoggedIn");
      break;
  }
}

void alertDialog() {

}

void _showToast(String data) {
  Fluttertoast.showToast(
      msg: data,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 2,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
