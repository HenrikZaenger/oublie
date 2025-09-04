import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oublie/dart_untis_mobile_local/lib/dart_untis_mobile.dart';
import 'package:oublie/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' as main;
import 'package:http/http.dart' as http;

class SearchResult {
  late String name;
  late String loginName;
  late String server;
  late String address;
  SearchResult(this.name, this.loginName, this.server, this.address);
}

class UntisLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UntisLoginState();
}

class _UntisLoginState extends State<UntisLogin> {

  FocusNode focusNode = FocusNode();
  TextEditingController search = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool loggingIn = false;

  bool searching = false;
  List<SearchResult> searchResults = List.empty(growable: true);
  SearchResult? selectedSearchResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                TextField(
                  focusNode: focusNode,
                  keyboardType: TextInputType.webSearch,
                  controller: search,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Schoul",
                    suffixIcon: IconButton(
                      onPressed: searching ? null : searchSchools,
                      icon: searching ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : Icon(Icons.search)
                    )
                  ),
                  onSubmitted: (_) {
                    if(!searching) searchSchools();
                    focusNode.requestFocus();
                  },
                ),
                if(focusNode.hasFocus && searchResults.isNotEmpty) Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: List.generate(searchResults.length, (index) {
                    return Card(
                      child: ListTile(
                        title: Text(searchResults[index].name),
                        subtitle: Text(searchResults[index].address),
                        onTap: () {
                          selectedSearchResult = searchResults[index];
                          search.text = selectedSearchResult!.name;
                          setState(() {
                            focusNode.unfocus();
                          });
                        },
                      ),
                    );
                  }),
                ),
                TextField(
                  autofillHints: [AutofillHints.username],
                  controller: username,
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Benotzernumm"),
                ),
                TextField(
                  autofillHints: [AutofillHints.password],
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Passwuert"),
                  onSubmitted: (_) {
                    if(loggingIn) return;
                    if(selectedSearchResult == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("WEG eng Schoul auswielen")
                          )
                      );
                      return;
                    }
                    if(username.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("WEG en Benotzernumm aginn")
                          )
                      );
                      return;
                    }
                    if(password.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("WEG en Passwuert aginn")
                          )
                      );
                      return;
                    }
                    setState(() {
                      loggingIn = true;
                    });
                    login(username.text, password.text, selectedSearchResult!.server, selectedSearchResult!.name).then((_) => setState(() {
                      loggingIn = false;
                    }));
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if(loggingIn) return;
                          if(selectedSearchResult == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("WEG eng Schoul auswielen")
                                )
                            );
                            return;
                          }
                          if(username.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("WEG en Benotzernumm aginn")
                                )
                            );
                            return;
                          }
                          if(password.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("WEG en Passwuert aginn")
                                )
                            );
                            return;
                          }
                          setState(() {
                            loggingIn = true;
                          });
                          try {
                            login(username.text, password.text,
                                selectedSearchResult!.server,
                                selectedSearchResult!.loginName).then((_) =>
                                setState(() {
                                  loggingIn = false;
                                })).then((_) {
                              TextInput.finishAutofillContext(shouldSave: true);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Navigation()));
                            });
                          } catch(e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: $e")
                              )
                            );
                            return;
                          }
                        },
                        child: Text("Login"),
                      ),
                    ),
                  ],
                ),
                Text("Passwuert Vergiess? Du kannst et an der Untis App zerëcksetzen")
              ],
            ),
          ),
        ),
      ),
    );
  }

  void searchSchools() async {
    setState(() {
      searching = true;
    });

    http.Response response = await http.get(
      Uri.parse("https://api.oublie.lu/proxy_search?query=${search.text}"),
    );

    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

    if(data["result"] == null) {
      setState(() {
        searching = false;
        searchResults = List.empty(growable: true);
      });
      return;
    }

    Map<String, dynamic> result0 = data["result"];

    List<dynamic> schools = result0["schools"];

    List<SearchResult> results = List.empty(growable: true);

    for (var school in schools) {
      SearchResult result = SearchResult(school["displayName"], school["loginName"], school["server"], school["address"]);
      results.add(result);
    }

    setState(() {
      searching = false;
      searchResults = results;
    });

  }

  Future<void> login(String username, String password, String server, String school) async {
    try {
      main.session = await UntisSession.init(server, school, username, password);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString("untisServer", server);
      await preferences.setString("untisUsername", username);
      await preferences.setString("untisSchool", school);
      FlutterSecureStorage secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: "untisPassword", value: password);
      await preferences.setBool("loggedIn", true);
    } catch(e) {
      rethrow;
    }
  }

}