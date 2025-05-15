// ignore_for_file: unused_local_variable, unused_import, override_on_non_overriding_member
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: AppBar(
              bottom: const TabBar(
                tabs: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('My Notes'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Add new Notes'),
                  ),
                ],
              ),
              backgroundColor: Colors.cyan,
            ),
          ),
          body: const TabBarView(
            children: [
              Allnotes(),
              Addnote(),
            ],
          ),
        ),
      ),
    );
  }
}

class Allnotes extends StatefulWidget {
  const Allnotes({super.key});

  @override
  State<Allnotes> createState() => _AllnotesState();
}

class _AllnotesState extends State<Allnotes> {
  List<Map<String, dynamic>> notes = [];
  bool editmode = false;
  late String editableenity;
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  void getNotes() async {
    final String path = join(await getDatabasesPath(), 'notes_data.db');
    final db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, description TEXT)');
      },
      version: 1,
    );
    notes = await db.query('notes');
    setState(() {});
    db.close();
  }

  void deletetheentity(uid) async {
    final String path = join(await getDatabasesPath(), 'notes_data.db');
    final db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, description TEXT)');
      },
      version: 1,
    );
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [uid],
    );
    getNotes();
    setState(() {});
    db.close();
  }

  void movetoeditmode(String uid, String titleText, String descriptionText) {
    title.text = titleText;
    description.text = descriptionText;
    editmode = true;
    editableenity = uid;
    setState(() {});
  }

  void editindb(String title, String description) async {
    final String path = join(await getDatabasesPath(), 'notes_data.db');
    final db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, description TEXT)');
      },
      version: 1,
    );
    await db.update(
      'notes',
      {
        'title': title,
        'description': description,
      },
      where: 'id = ?',
      whereArgs: [editableenity],
    );
    db.close();
    editmode = false;
    getNotes();
    setState(() {});
  }

  @override
  void initState() {
    getNotes();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !editmode
        ? Scaffold(
            body: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(notes[index]['title']),
                        subtitle: Text(notes[index]['description']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                deletetheentity(notes[index]['id']);
                              },
                              icon: const Icon(Icons.delete_forever),
                            ),
                            IconButton(
                              onPressed: () {
                                movetoeditmode(
                                    notes[index]['id'],
                                    notes[index]['title'],
                                    notes[index]['description']);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        height: 2,
                      ),
                    ],
                  );
                }),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                    child: Text(
                      'Edit mode',
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: title,
                      maxLines: 2,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: description,
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            editindb(title.text, description.text);
                          });
                          title.clear();
                          description.clear();
                        },
                        child: const Text("Save My Note"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          editmode = false;
                          editableenity = "";
                          setState(() {});
                        },
                        child: const Text("Back to My Notes"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class Addnote extends StatefulWidget {
  const Addnote({super.key});

  @override
  State<Addnote> createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  @override
  void initstate() {
    super.initState();
  }

  Future<void> inserttobd(String title, String description) async {
    final String path = join(await getDatabasesPath(), 'notes_data.db');
    final db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT, description TEXT)',
        );
      },
      version: 1,
    );
    String id = UniqueKey().toString();
    await db.insert(
        'notes',
        {
          'id': id,
          'title': title,
          'description': description,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    db.close();
  }

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: title,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: description,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  inserttobd(title.text, description.text);
                });
                title.clear();
                description.clear();
              },
              child: const Text("save my note"),
            )
          ],
        ),
      ),
    );
  }
}
