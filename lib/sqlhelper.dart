// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SQLHelper {
  /////////////////////////////////
  ///////// GET DATABSE //////////
  ///////////////////////////////
  static Database? _database;
  static get getDatabase async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  //////////////////////////////////////////////
  //////////// INITIALIZE DATABASE ////////////
//////////////////////////////////////////////
//////////// CREATE & UPGRADE ///////////////

  static Future<Database> initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future _onCreate(Database db, int verstion) async {
    Batch batch = db.batch();
    batch.execute('''
CREATE TABLE notes (
  id INTEGER PRIMARY KEY,
  title TEXT,
  content TEXT,
  description TEXT NULL
)
''');

    batch.execute('''
CREATE TABLE todos (
  id INTEGER PRIMARY KEY,
  title TEXT,
  value BOOL
)
''');
    batch.commit();

    print('on create was called');
  }

  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('ALTER TABLE notes ADD COLUMN description TEXT NULL ');

    await db.execute('''
CREATE TABLE todos (
  id INTEGER PRIMARY KEY,
  title TEXT,
  value BOOL
)
''');

    print('on uprade was called');
  }

  //////////////////////////////////////////////////////
  /////////////// INSERT DATA INTO DATABASE ///////////
//////////////////////////////////////////////////////
  static Future insertNote(Note note) async {
    Database db = await getDatabase;
    Batch batch = db.batch();
    batch.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    /*  batch.insert('todos', {'title': note.title, 'value': 0},
        conflictAlgorithm: ConflictAlgorithm.replace); */
    batch.commit();
    print(await db.query('notes'));
  }

  static Future insertTodo(Todo todo) async {
    Database db = await getDatabase;
    await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print(await db.query('todos'));
  }

  static Future insertNoteRaw() async {
    Database db = await getDatabase;
    await db.rawInsert('INSERT INTO notes(title, content) VALUES(?, ?)',
        ['another name', '12345678']);
    print(await db.rawQuery('SELECT * FROM notes'));
  }

  //////////////////////////////////////////////////////
  /////////////// RETREIVE DATA FROM DATABASE /////////
//////////////////////////////////////////////////////
  static Future<List<Map>> loadNotes() async {
    Database db = await getDatabase;
    List<Map> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        description: maps[i]['description'],
      ).toMap();
    });
  }

  static Future<List<Map>> loadTodos() async {
    Database db = await getDatabase;
    List<Map> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        value: maps[i]['value'],
      ).toMap();
    });
  }

  //////////////////////////////////////////////////////
  /////////////// UPDATE DATA IN DATABASE /////////////
//////////////////////////////////////////////////////

  static Future updateNote(Note newNote) async {
    Database db = await getDatabase;
    await db.update('notes', newNote.toMap(),
        where: 'id=?', whereArgs: [newNote.id]);
  }

  static Future updateNoteRaw(Note newNote) async {
    Database db = await getDatabase;
    await db.rawUpdate('UPDATE notes SET title = ?, content = ? WHERE id = ?',
        [newNote.title, newNote.content, newNote.id]);
  }

  static Future updateTodoChecked(int id, int currentValue) async {
    Database db = await getDatabase;
    await db.rawUpdate('UPDATE todos SET value = ? WHERE id = ?',
        [currentValue == 0 ? 1 : 0, id]);
  }

  //////////////////////////////////////////////////////
  //////////////// DELETE DATA FROM DATABASE //////////
  ////////////////////////////////////////////////////

  static Future deleteNote(int id) async {
    Database db = await getDatabase;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future deleteNoteRaw(int id) async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM notes WHERE id = ?', [id]);
  }

  static Future deleteAllNotesRaw() async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM notes');
  }

  static Future deleteAllNotes() async {
    Database db = await getDatabase;
    await db.delete('notes');
  }

  static Future deleteAllTodosRaw() async {
    Database db = await getDatabase;
    await db.rawDelete('DELETE FROM todos');
  }

  static Future deleteAllTodos() async {
    Database db = await getDatabase;
    await db.delete('todos');
  }
}

class Note {
  final int? id;
  final String title;
  final String content;
  String? description;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Note{id:$id , title: $title , content:$content , description:$description}';
  }
}
///////////////////////////////////////
////////////// TOdO CLASS /////////////
///////////////////////////////////////

class Todo {
  final int? id;
  final String title;
  int value;

  Todo({this.id, required this.title, this.value = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'Note{id:$id , title: $title , value:$value }';
  }
}
/////////////////////////////////////////
/////////////// NOTE CLASS //////////////
/////////////////////////////////////////