import 'dart:convert';
import 'dart:core';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:oublie/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BicherView extends StatefulWidget {
  const BicherView({super.key, required this.title});

  final String title;

  @override
  State<BicherView> createState() => _BicherViewState();
}

class _BicherViewState extends State<BicherView> {

  bool loading = true;

  Set<UntisSubject> subjects = {};
  List<List<String>> books = [];
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {};
    for(int i = 0; i < subjects.length; i++) {
      data["${subjects.elementAt(i).id.id}"] = books[i];
    }

    prefs.setString("books", jsonEncode(data));

  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UntisSession? session = UntisManager.session;

    Map<String, dynamic> booksJson = jsonDecode(
        prefs.getString("books") ?? "{}");

    DateTime now = DateTime.now();
    DateTime thisMonday = now.subtract(
        Duration(days: now.weekday - DateTime.monday));
    DateTime mondayInTwoWeeks = thisMonday.add(Duration(days: 7 * 2));

    int classID = prefs.getInt("classID") ?? 0;

    final UntisTimetable? table;

    if (classID == 0) {
      table = await session?.getTimetable(
        startDate: thisMonday,
        endDate: mondayInTwoWeeks,
      );
    } else {
      table = await session?.getTimetable(
        startDate: thisMonday,
        endDate: mondayInTwoWeeks,
        id: UntisElementDescriptor(UntisElementType.classElement, classID),
      );
    }

    for (UntisPeriod period in table!.periods) {
      for (UntisSubject subject in period.subjects) {
        subjects.add(subject);
      }
    }

    for (UntisSubject i in subjects) {
      if (booksJson.containsKey("${i.id.id}")) {
        List<dynamic> dynamicBooks = booksJson["${i.id.id}"];
        List<String> stringBooks = dynamicBooks.map((item) => item.toString()).toList();
        books.add(stringBooks);
      } else {
        books.add([]);
      }
      expanded.add(false);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _removeSubIndex(int index, int subIndex) async {
    setState(() {
      books[index].removeAt(subIndex);
    });
    saveData();
  }

  Future<void> addItem(int subjectIndex) async {

    TextEditingController controller = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Den numm vum Buch aginn:"),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  controller: controller,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if(controller.text.isEmpty) return;
                  setState(() {
                    books[subjectIndex].add(controller.text);
                  });
                  saveData();
                },
                child: const Text("Ok")
              )
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          if (expanded[index]) {
            int subCounter = 0;
            return Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      subjects.elementAt(index).longName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    trailing: Icon(Icons.expand_less),
                    onTap: () {
                      setState(() {
                        expanded[index] = !expanded[index];
                      });
                    },
                  ),
                  Column(
                    children: books[index].map<Widget>((name) {
                      subCounter++;
                      return Padding(
                        padding: EdgeInsets.only(left: 32.0),
                        child: ListTile(
                          title: Text(name),
                          trailing: IconButton(
                            onPressed: () => _removeSubIndex(index, subCounter - 1),
                            icon: Icon(Icons.delete_forever, color: Colors.redAccent)
                          ),
                        ),
                      );
                    }).toList()
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 32.0),
                    child: ListTile(
                      title: Text("Hinzufügen"),
                      onTap: () => addItem(index),
                      leading: Icon(Icons.add_circle),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      subjects.elementAt(index).longName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    trailing: Icon(Icons.expand_more),
                    onTap: () {
                      setState(() {
                        expanded[index] = !expanded[index];
                      });
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              final params = ShareParams(
                files: [XFile.fromData(utf8.encode(prefs.getString("books") ?? "{}"), mimeType: 'text/plain')],
                fileNameOverrides: ['oubliebooks.txt']
              );

              await SharePlus.instance.share(params);
            },
            icon: Icon(Icons.share)
          ),
          IconButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['txt'],
              );

              if(result != null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                PlatformFile file = result.files.first;

                setState(() {
                  prefs.setString("books", utf8.decode(file.bytes!));
                });

              }

            },
            icon: Icon(Icons.file_download)
          )
        ],
        title: Text("Schoulbicher"),
      ),
    );
  }
}