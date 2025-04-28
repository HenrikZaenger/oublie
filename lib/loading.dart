import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/material.dart';
import 'package:oublie/main.dart';
import 'package:oublie/main_navigation_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;

    if (loggedIn) {
      // Try connecting to Untis
      try {
        final server = prefs.getString('server') ?? '';
        final school = prefs.getString('school') ?? '';
        final username = prefs.getString('username') ?? '';
        final password = prefs.getString('password') ?? '';

        UntisManager.session = await UntisSession.init(
          server,
          school,
          username,
          password,
        );

        // Connection successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigationView(page: 0)),
        );
      } catch (e) {
        print('Failed to connect: $e');
        // Login failed, redirect to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SelectSchoolView()),
        );
      }
    } else {
      // Not logged in, redirect to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SelectSchoolView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Simple loading indicator
      ),
    );
  }
}