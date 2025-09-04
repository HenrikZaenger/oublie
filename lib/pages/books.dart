import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oublie/dart_untis_mobile_local/lib/dart_untis_mobile.dart';
import 'package:oublie/main.dart' as main;

class Books extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksState();
}

class _BooksState extends State<Books> {

  bool loading = false;
  List<UntisSubject> subjects = List.empty(growable: true);
  Map<String, List<dynamic>> books = {};
  Map<int, List<bool>> selected = {};

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Bicher"),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        )
      );
    }
    bool empty = true;
    for (var subject in subjects) {
      if(!(books["${subject.id.id}"] ?? []).isEmpty) {
        empty = false;
      }
    }
    if(empty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Bicher"),
        ),
        body: Center(
          child: Text("Muer brauchs du keng Saachen :)", textAlign: TextAlign.center,),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Bicher"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(subjects.length, (subjectIndex) {
              List<dynamic> currentBooks = books["${subjects[subjectIndex].id.id}"] ?? [];
              if(currentBooks.isEmpty) {
                return SizedBox();
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(subjects[subjectIndex].longName, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 10, width: double.infinity),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: List.generate(currentBooks.length, (bookIndex) {
                          return ListTile(
                            title: Text(currentBooks[bookIndex]),
                            leading: (selected[subjects[subjectIndex].id.id] ?? []).elementAt(bookIndex) ? Icon(Icons.circle) : Icon(Icons.circle_outlined),
                            onTap: () {
                              setState(() {
                                selected[subjects[subjectIndex].id.id]![bookIndex] = !selected[subjects[subjectIndex].id.id]![bookIndex];
                              });
                            },
                          );
                        }),
                      )
                    ]
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, dynamic> booksTemp = jsonDecode(preferences.getString("untisBicher") ?? "{}");
    booksTemp.forEach((k, v) {
      List<dynamic> bookTemp = v;
      books[k] = bookTemp;
      for(var book1 in bookTemp) {
        if(selected[int.parse(k)] == null) selected[int.parse(k)] = List.empty(growable: true);
        selected[int.parse(k)]!.add(false);
      }
    });
    subjects = await getSubjects();

    setState(() {
      loading = false;
    });
  }

  Future<List<UntisSubject>> getSubjects() async {

    List<UntisSubject> subjects = List.empty(growable: true);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day, 23, 59);
    DateTime tomorrow = today.add(Duration(days: 1));

    List<UntisPeriod> periods = await main.session!.getTimetablePeriods(
      (await main.session!.getUserData()).id,
      startDate: today,
      endDate: tomorrow
    );

    for (var period in periods) {
      if(period.endDateTime.isBefore(tomorrow) && period.startDateTime.isAfter(today)) {
        for (var subject in period.subjects) {
          if(!subjects.contains(subject)) {
            subjects.add(subject);
          }
        }
      }
    }

    return subjects;

  }

}