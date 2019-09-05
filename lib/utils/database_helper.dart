//import 'dart:core';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:final_app/models/note.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHalper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';



  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if(_databaseHalper == null){
      _databaseHalper = DatabaseHelper._createInstance();
    }
    return _databaseHalper;
  }

  Future<Database> get database async{
    if(_database == null){
      _database = await initalizationDatabase();
    }
    return _database;
  }

  Future<Database> initalizationDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();  
    String path = directory.path + 'notes.db';
    

   var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDB);
   return notesDatabase;
  }

  void _createDB(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String,dynamic>>> getNoteMapList() async{
    Database db = await this.database;
    var result = await db.query(noteTable,orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result =  await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async{
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async{
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for(int i = 0;i<count;i++)
    {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

}