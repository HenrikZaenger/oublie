import 'package:flutter/material.dart';

class PunktenView extends StatefulWidget {
  const PunktenView({super.key, required this.title});
  final String title;
  @override
  State<PunktenView> createState() => _PunktenViewState();
}

class _PunktenViewState extends State<PunktenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Coming soon!",
          textScaler: TextScaler.linear(2),
        ),
      ),
    );
  }
}