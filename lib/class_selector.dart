import 'package:flutter/material.dart';
import 'package:dart_untis_mobile/dart_untis_mobile.dart';
import 'package:oublie/main.dart';
import 'package:oublie/main_navigation_view.dart';
import 'package:oublie/pages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassSelector extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ClassSelectorState();

}

class _ClassSelectorState extends State<ClassSelector> {
  bool loading = true;
  List<UntisClass>? classes;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    UntisSession? session = UntisManager.session;
    classes = await session?.classes;
    setState(() {
      loading = false;
    });
  }

  Future<void> saveClass(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(index == -1) {
      prefs.setInt("classID", 0);
    } else {
      prefs.setInt("classID", classes![index].id.id);
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavigationView(page: 3)));
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
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavigationView(page: 3)));
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: ListView.builder(
        itemCount: classes!.length + 1,
        itemBuilder: (context, index) {
          if(index == 0) {
            return ListTile(
              title: Text('Perséinlech'),
              subtitle: Text('ActPa ginn och ugewissen!'),
              onTap: () => saveClass(-1),
            );
          }
          return ListTile(
            title: Text(classes![index - 1].longName),
            onTap: () => saveClass(index - 1),
          );
        },
      ),
    );
  }
}