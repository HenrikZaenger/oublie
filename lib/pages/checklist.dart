import 'dart:convert';

import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:flutter/material.dart';
import 'package:oublie/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistView extends StatefulWidget {
  const ChecklistView({super.key, required this.title});
  final String title;

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  Map<String, List<String>> subjectSubitems = {};
  Map<String, Set<String>> checkedItems = {};
  Set<UntisSubject?> subjects = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDataAndTimetable();
  }

  Future<void> loadDataAndTimetable() async {
    final prefs = await SharedPreferences.getInstance();

    // Load subitems from SharedPreferences
    final jsonString = prefs.getString('books') ?? '{}';
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    subjectSubitems = decoded.map((key, value) => MapEntry(key, List<String>.from(value)));

    // Initialize checked state
    checkedItems = {
      for (var key in subjectSubitems.keys) key: <String>{},
    };

    // Fetch tomorrow's timetable
    final tomorrow = getTomorrowDate();
    final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0);
    final end = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);

    try {
      final timetable = await UntisManager.session!.getTimetable(
        startDate: start,
        endDate: end,
      );

      // Filter periods actually happening tomorrow
      for(UntisPeriod period in timetable.periods) {
        if(period.startDateTime.isAfter(start) && period.endDateTime.isBefore(end)) {
          subjects.add(period.subject);
        }
      }
    } catch (e) {
      print('Error fetching timetable: $e');
    }

    setState(() {
      loading = false;
    });
  }

  DateTime getTomorrowDate() {
    final now = DateTime.now();
    return now.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fächer muer'),
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects.elementAt(index);

          final subitems = subjectSubitems["${subject?.id.id}"] ?? [];

          if (subitems.isEmpty) {
            return const SizedBox();
          }

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject!.longName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subitems.length,
                    itemBuilder: (context, subIndex) {
                      final subitem = subitems[subIndex];
                      final isChecked = checkedItems["${subject.id.id}"]?.contains(subitem) ?? false;

                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 16, right: 16),
                        title: Text(subitem),
                        trailing: isChecked ? Icon(Icons.check_circle) : Icon(Icons.circle_outlined),
                        onTap: () {
                          setState(() {
                            if (!isChecked) {
                              checkedItems["${subject.id.id}"]?.add(subitem);
                            } else {
                              checkedItems["${subject.id.id}"]?.remove(subitem);
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}