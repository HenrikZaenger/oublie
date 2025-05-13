import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oublie/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectSchoolView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelectSchoolViewState();
}

class _SelectSchoolViewState extends State<SelectSchoolView> {
  List<dynamic> schools = [];
  bool isLoading = false;
  final TextEditingController controller = TextEditingController();

  Future<void> searchSchools(String query) async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://oublie.h12z.me/schoolsearch?s=$query');

    final response = await http.get(url);
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      setState(() {
        schools = jsonDecode(response.body)["result"]["schools"];
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Schoulen konnten net gelueden ginn')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schrett 1: Schoul auswielen')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              onSubmitted: searchSchools,
              decoration: InputDecoration(
                hintText: 'Schoulnumm aginn',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => searchSchools(controller.text),
                ),
              ),
            ),
          ),
          if (isLoading) CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: schools.length,
              itemBuilder: (context, index) {
                final school = schools[index];
                return ListTile(
                  title: Text(school['displayName']),
                  subtitle: Text(school['address']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(selectedSchool: school),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Map<String, dynamic> selectedSchool;

  const LoginScreen({required this.selectedSchool});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  Future<void> login() async {
    final user = userController.text.trim();
    final pass = passController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WEG all felder ausfellen')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("loggedIn", true);
    prefs.setString("server", widget.selectedSchool["server"]);
    prefs.setString("school", widget.selectedSchool["loginName"]);
    prefs.setString("username", user);
    prefs.setString("password", pass);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = widget.selectedSchool['displayName'];
    return Scaffold(
      appBar: AppBar(title: Text('Step 2: Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected School: $schoolName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'IAM (ouni @school.lu)'),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              onSubmitted: (_) => login,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: login,
                child: Text('Login'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                textAlign: TextAlign.center,
                "Wann du däin passwuert net wees kanns du en\nan der Untis app enner \"Profil\", \"Passwort ändern\"\nan \"Passwort vergessen\" zerècksetzen."
              )
            )
          ],
        ),
      ),
    );
  }
}

final Uri _url = Uri.parse('https://instructions.h12z.me/');

Future<void> _launchURL() async {
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $_url');
  }
}