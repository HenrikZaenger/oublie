import 'package:flutter/material.dart';
import 'package:oublie/pages/bicher.dart';
import 'package:oublie/pages/checklist.dart';
import 'package:oublie/pages/punkten.dart';
import 'package:oublie/pages/settings.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key, required this.page});
  final int page;
  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int currentPageIndex = 0;

  @override
  void initState() {
    currentPageIndex = widget.page;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
              icon: Icon(Icons.check),
              label: 'Checklist'
          ),
          NavigationDestination(
              icon: Icon(Icons.circle_outlined),
              selectedIcon: Icon(Icons.circle),
              label: 'Punkten'
          ),
          NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Bicher'
          ),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Astellungen'
          ),
        ]
      ),
      body: <Widget>[
        ChecklistView(title: 'Checklist'),
        PunktenView(title: 'Punkten'),
        BicherView(title: 'Bicher'),
        SettingsView(title: 'Settings'),
      ][currentPageIndex],
    );
  }
}