import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oublie/dart_untis_mobile_local/lib/dart_untis_mobile.dart';
import 'package:oublie/main.dart' as main;
import 'package:oublie/untis_login.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool loading = false;
  String displayName = "error";
  String username = "error";
  List<UntisSubject> subjects = List.empty(growable: true);
  Map<String, List<dynamic>> books = {};
  Map<int, bool> expanded = {};

  @override
  void initState() {
    loadData();
    super.initState();
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
      appBar: AppBar(
        title: Text("Astellungen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
                      ListTile(
                        title: Text(displayName),
                        subtitle: Text(username),
                      ),
                      Center(
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: logout,
                          child: Text("Ausloggen"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      Text("Bicher", style: TextStyle(fontWeight: FontWeight.bold)),
                      if(subjects.isNotEmpty) Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(subjects.length, (index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(subjects[index].longName, style: TextStyle(fontWeight: FontWeight.bold)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Text("${(books["${subjects[index].id.id}"] ?? []).length}"),
                                    ),
                                    Icon(
                                      expanded[subjects[index].id.id]! ? Icons.expand_less : Icons.expand_more
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    expanded[subjects[index].id.id] = !(expanded[subjects[index].id.id] ?? false);
                                  });
                                },
                              ),
                              if(expanded[subjects[index].id.id]!) SizedBox(height: 10,),
                              if(expanded[subjects[index].id.id]!) Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: List.generate((books["${subjects[index].id.id}"] ?? []).length + 1, (jindex) {
        
                                  if((books["${subjects[index].id.id}"] ?? []).length == jindex) {
                                    return Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: ListTile(
                                        title: Text("Buch hinzufügen"),
                                        leading: Icon(Icons.add),
                                        onTap: () {
                                          editBook(subjects[index].id.id, jindex, "", true);
                                        },
                                      ),
                                    );
                                  }
        
                                  return Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: ListTile(
                                      title: Text((books["${subjects[index].id.id}"] ?? [])[jindex]),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 10,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {editBook(subjects[index].id.id, jindex, (books["${subjects[index].id.id}"] ?? [])[jindex], false);},
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () {
                                              setState(() {
                                                books["${subjects[index].id.id}"]!.removeAt(jindex);
                                                saveBooks();
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              )
                            ],
                          );
                        }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: share,
                          ),
                          IconButton(
                            icon: Icon(Icons.upload),
                            onPressed: import,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void share() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SharePlus.instance.share(ShareParams(
      fileNameOverrides: ["OublieBooks.json"],
      files: [XFile.fromData(utf8.encode(preferences.getString("untisBicher") ?? ""))]
    ));
  }

  void import() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["json"],
      withData: true
    );
    if(result == null) {
      return;
    }
    if (result.files.first.name.toLowerCase().endsWith('.json')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid datei')),
      );
      return;
    }
    String data = utf8.decode(result.files.first.bytes!);
    preferences.setString("untisBicher", data);
    Map<String, dynamic> booksTemp = jsonDecode(data);
    booksTemp.forEach((k, v) {
      List<dynamic> bookTemp = v;
      books[k] = bookTemp;
    });
  }

  void editBook(int subjectId, int bookIndex, String oldText, bool add) async {
    String newText = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        TextEditingController book = TextEditingController(text: oldText);
        return AlertDialog(
          title: Text("Buch bearbeschten/hinzufügen"),
          content: TextField(
            controller: book,
            onSubmitted: (text) {
              if(text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Du musst en numm fir d'buch aginn!")));
              }
              Navigator.pop(context, text);
            },
          ),
          actions: [
            FilledButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, oldText);
              },
            ),
            FilledButton(
              child: Text("OK"),
              onPressed: () {
                if(book.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Du musst en numm fir d'buch aginn!")));
                }
                Navigator.pop(context, book.text);
              },
            )
          ],
        );
      }
    ) ?? "";
    if(newText.isEmpty) return;
    setState(() {
      if(books["$subjectId"] == null) {
        books["$subjectId"] = List.empty(growable: true);
      }
      if(add) {
        books["$subjectId"]!.add(newText);
      } else {
        books["$subjectId"]![bookIndex] = newText;
      }
    });
    saveBooks();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    displayName = (await main.session!.getUserData()).displayName;
    username = (await main.session!.getUserData()).username;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, dynamic> booksTemp = jsonDecode(preferences.getString("untisBicher") ?? "{}");
    booksTemp.forEach((k, v) {
      List<dynamic> bookTemp = v;
      books[k] = bookTemp;
    });
    subjects = await getSubjects();
    for (var subject in subjects) {
      expanded[subject.id.id] = false;
    }
    setState(() {
      loading = false;
    });
  }

  void saveBooks() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("untisBicher", jsonEncode(books));
  }

  void logout() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    secureStorage.delete(key: "untisPassword");

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UntisLogin()));

  }

  Future<List<UntisSubject>> getSubjects() async {

    List<UntisSubject> subjects = List.empty(growable: true);

    List<UntisPeriod> periods = await main.session!.getTimetablePeriods(
      (await main.session!.getUserData()).id,
      startDate: DateTime.now().subtract(Duration(days: 14)),
      endDate: DateTime.now()
    );

    for (var period in periods) {
      for (var subject in period.subjects) {
        if(!subjects.contains(subject)) {
          subjects.add(subject);
        }
      }
    }

    return subjects;

  }

}