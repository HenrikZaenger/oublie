import 'package:flutter/material.dart';
import 'package:oublie/class_selector.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:oublie/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
      UntisClass? classData = await session.getClassById(classID);
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                "Klass",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(className),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClassSelector()));
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                "Open source Licenses",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
          ),
          Spacer(),
          Card(
            margin: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: _launchURL,
              child: Text(
                "Patreon",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          ),
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                "About",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _launchPrivacyPolicyURL();
              },
            ),
          )
        ],
      ),
      appBar: AppBar(
        title: Text(username),
      ),
    );
  }
}

final Uri _url = Uri.parse('https://www.patreon.com/h12zstudios');

Future<void> _launchURL() async {
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $_url');
  }
}

final Uri _privacyPolicyURL = Uri.parse('https://aboutoublie.h12z.me/');

Future<void> _launchPrivacyPolicyURL() async {
  if (!await launchUrl(_privacyPolicyURL, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $_url');
  }
}