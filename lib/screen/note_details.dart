import 'package:flutter/material.dart';
import 'dart:async';
import 'package:final_app/models/note.dart';
import 'package:final_app/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetails extends StatefulWidget {
  final appbartitle;
  final Note note;

  NoteDetails(this.note,this.appbartitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailsState(this.note,this.appbartitle);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appbarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailsState(this.note,this.appbarTitle); 

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description ;

    return WillPopScope(
      onWillPop: ()
      {
        moveBack();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(appbarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            moveBack();
          },
        ),
      ),
      body:  Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropdownItem) {
                  return DropdownMenuItem<String>(
                      value: dropdownItem, child: Text(dropdownItem));
                }).toList(),
                style: textStyle,
                value: getPriorityAsString(note.priority),
                onChanged: (userValue) {
                  setState(() {
                    debugPrint('Dropdown Value is $userValue');
                    updatePriorityAsInt(userValue);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                   onChanged : (value) {
                   debugPrint('Title is Changed');
                   updatetitle();
                 },
                decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter Note Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Description Value Changed');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter Note Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        setState(() {
                          debugPrint('Save Clicked');
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text(
                        'Delete',
                        textScaleFactor: 1.5,
                      ),
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        setState(() {
                          debugPrint('Delete Clicked');
                          _delete();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

void moveBack() async
{
  Navigator.pop(context,true);
}

void updatePriorityAsInt(String value){
  switch(value){
    case 'High':
    note.priority = 1;
    break;

    case 'Low':
    note.priority = 2;
    break;
  }
}

String getPriorityAsString(int value){
  String priority;
  switch(value){
    case 1:
    priority = _priorities[0];
    break;

    case 2:
    priority = _priorities[1];
    break;
  }
  return priority;
}

void updatetitle(){
  note.title = titleController.text;
}

void updateDescription(){
  //debugPrint("update description");
  note.description = descriptionController.text;
}

void _save() async{
  moveBack();

  note.date = DateFormat.yMMMd().format(DateTime.now());
  int result;
  if(note.id != null){
    result = await helper.updateNote(note);
  }
  else{
    result = await helper.insertNote(note);
  }

  if(result != 0){
      _showAlertDialog('Status','Note Saved Successfully');
  }else{
      _showAlertDialog('Status','Problems Saving Note');
  }
}

void _delete() async{

  moveBack();

  if(note.id == null){
    _showAlertDialog('Status', 'No Note was deleted');
    return;
  }

  int result = await helper.deleteNote(note.id);

  if(result != 0){
    _showAlertDialog('Status', 'Note Deleted Successfully');
  }
  else{
    _showAlertDialog('Status', 'Error Occured while Deleting Note');
  }

}

void _showAlertDialog(String title,String message){
  AlertDialog alertDialog = AlertDialog(
    title: Text(title),
    content: Text(message),
  );
  showDialog(
    context: context,
    builder: (_) => alertDialog
  );
}

// String validation(String value)
// {
//   if(value.isEmpty)
//   {
//     new TextFormField(validator: (value){
//       return 'Enter Title';
//     },);
//   }
//   else{
//     updatetitle();
//   }
// }

}
