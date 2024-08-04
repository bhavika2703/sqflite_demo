import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqllite_example/sqlhelper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SQLHelper.getDatabase;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Notes App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  late String newTitle;
   String? newContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                SQLHelper.deleteAllTodos();
                SQLHelper.deleteAllNotes().whenComplete(() => setState(() {}));
              },
              icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: Center(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder(
                    future: SQLHelper.loadNotes(),
                    builder:
                        (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Dismissible(
                                  key: UniqueKey(),
                                  onDismissed: (direction) => SQLHelper.deleteNote(
                                      snapshot.data![index]['id']),
                                  child: Card(
                                    color: Colors.purpleAccent,
                                    child: Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              showMyDialogEdit(
                                                  context,
                                                  snapshot.data![index]['title'],
                                                  snapshot.data![index]['content'],
                                                  snapshot.data![index]['id']);
                                              /*  SQLHelper.updateNote(Note(
                                                      id: snapshot.data![index]['id'],
                                                      title: titleController.text,
                                                      content: 'content'))
                                                  .whenComplete(() => setState(() {})); */
                                            },
                                            icon: const Icon(Icons.edit)),
                                        Text(('id:  ') +
                                            (snapshot.data![index]['id']
                                                .toString())),
                                        Text(('title:  ') +
                                            (snapshot.data![index]['title']
                                                .toString())),
                                        Text(('content:  ') +
                                            (snapshot.data![index]['content']
                                                .toString())),
                                        Text(('description:  ') +
                                            (snapshot.data![index]['description']
                                                .toString())),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ),
              Expanded(
                child: FutureBuilder(
                    future: SQLHelper.loadTodos(),
                    builder:
                        (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                bool isDone = snapshot.data![index]['value'] == 0
                                    ? false
                                    : true;
                                return Card(
                                    color:
                                    isDone == false ? Colors.red : Colors.green,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            activeColor: Colors.red,
                                            value: isDone,
                                            onChanged: (bool? value) {
                                              SQLHelper.updateTodoChecked(
                                                  snapshot.data![index]['id'],
                                                  snapshot.data![index]
                                                  ['value'])
                                                  .whenComplete(
                                                      () => setState(() {}));
                                            }),
                                        Text(
                                          snapshot.data![index]['title'],
                                          style: TextStyle(
                                              color: isDone == false
                                                  ? Colors.black
                                                  : Colors.white),
                                        )
                                      ],
                                    ));
                              });
                        }
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ),
            ],
          )),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.purpleAccent,
            onPressed: () async {
              showMyDialog(context);
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async {
                showMyDialogTodo(context);
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void showMyDialog(context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => Material(
        color: Colors.white.withOpacity(0.3),
        child: CupertinoAlertDialog(
          title: const Text('Add New Note'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
              ),
              TextField(
                controller: contentController,
              ),
            ],
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                //   SQLHelper.insertNoteRaw();
                SQLHelper.insertNote(Note(
                    title: titleController.text,
                    content: contentController.text,
                    description: 'description4444'))
                    .whenComplete(() => setState(() {}));
                titleController.clear();
                contentController.clear();
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            )
          ],
        ),
      ),
    );
  }

  void showMyDialogTodo(context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => Material(
        color: Colors.white.withOpacity(0.3),
        child: CupertinoAlertDialog(
          title: const Text('Add New Todo'),
          content: TextField(
            controller: titleController,
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                //   SQLHelper.insertNoteRaw();
                SQLHelper.insertTodo(Todo(title: titleController.text))
                    .whenComplete(() => setState(() {}));
                titleController.clear();
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            )
          ],
        ),
      ),
    );
  }

  void showMyDialogEdit(context, String titleInit, String contentInit, int id) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => Material(
        color: Colors.white.withOpacity(0.3),
        child: CupertinoAlertDialog(
          title: const Text('Edit  Note'),
          content: Column(
            children: [
              TextFormField(
                initialValue: titleInit,
                //   controller: titleController,
                onChanged: (value) {
                  newTitle = value;
                },
              ),
              TextFormField(
                initialValue: contentInit,
                //   controller: titleController,
                onChanged: (value) {
                  newContent = value;
                },
              ),
            ],
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                // SQLHelper.updateNoteRaw(
                //  Note(id: id, title: newTitle, content: newContent))
                SQLHelper.updateNote(Note(
                    id: id,
                    title: newTitle,
                    content: newContent ?? 'content',
                    description: 'new description'))
                    .whenComplete(() => setState(() {}));
                titleController.clear();
                contentController.clear();
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            )
          ],
        ),
      ),
    );
  }
}
