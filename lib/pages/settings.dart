import 'package:flutter/material.dart';
import 'package:oublie/class_selector.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:oublie/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.title});
  final String title;
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  bool loading = true;
  String className = "";
  String username = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    UntisSession? session = UntisManager.session;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UntisStudentData data = await session!.getUserData();
    username = data.displayName;
    int classID = prefs.getInt("classID") ?? 0;
    if(classID == 0) {
      className = "Perséinlech";
    } else {
      UntisClass? classData = await session?.getClassById(classID);
      className = classData?.longName ?? "Error";
    }
     setState(() {
       loading = false;
     });
  }

  @override
  Widget build(BuildContext context) {
    if(loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text("Klass"),
            subtitle: Text(className),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClassSelector()));
            },
          )
        ],
      ),
      appBar: AppBar(
        title: Text(username),
      ),
    );
  }
}