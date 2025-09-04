import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oublie/pages/books.dart';
import 'package:oublie/pages/homework.dart';
import 'package:oublie/pages/noten.dart';
import 'package:oublie/pages/settings.dart';

class Navigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        Books(),
        Homework(),
        Noten(),
        Settings()
      ][index],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: "Bicher",
          ),
          NavigationDestination(
            icon: Icon(Icons.notes),
            label: "Hausaufgaben",
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: "Noten"
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Astellungen"
          )
        ],
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
      ),
    );
  }
}