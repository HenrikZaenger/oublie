import 'dart:io';

import 'package:oublie/dart_untis_mobile_local/lib/dart_untis_mobile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oublie/navigation.dart';
import 'package:oublie/untis_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

UntisSession? session;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Oublie',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: Loading(),
      debugShowCheckedModeBanner: false,
    );

  }
}

class Loading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    loadData(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

void loadData(BuildContext context) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  FlutterSecureStorage secureStorage = FlutterSecureStorage();

  bool loggedIn = sharedPreferences.getBool("loggedIn") ?? false;

  if(loggedIn) {

    session = await UntisSession.init(
        sharedPreferences.getString("untisServer") ?? "",
        sharedPreferences.getString("untisSchool") ?? "",
        sharedPreferences.getString("untisUsername") ?? "",
        await secureStorage.read(key: "untisPassword") ?? ""
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Navigation()));

  } else {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UntisLogin()));
  }

}