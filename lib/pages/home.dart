import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> band = [
    Band(id: '1', name: 'metallica', votes: 5),
    Band(id: '3', name: 'Heores del silencio', votes: 1),
    Band(id: '4', name: 'Chaucha king', votes: 2),
    Band(id: '5', name: 'Bon Jovi', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'BandName',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: band.length,
        itemBuilder: (BuildContext context, int index) =>
            _bandTitle(band[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addnewBand,
        child: Icon(Icons.add),
      ),
    );
  }

  _addnewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New Band Name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  _addBandToLis(textController.text);
                },
                child: Text('Agregar'),
                elevation: 5,
                textColor: Colors.blue,
              )
            ],
          );
        },
      );
    }

    //showCupertinoDialog(
    //  context: context,
    //  builder: (_) {
    //    return CupertinoAlertDialog(
    //      title: Text('New Band Name'),
    //      content: CupertinoTextField(
    //        controller: textController,
    //      ),
    //      actions: [
    //        CupertinoDialogAction(
    //          child: Text('Add'),
    //          isDefaultAction: true,
    //          onPressed: () => _addBandToLis(textController.text),
    //        ),
    //      ],
    //    );
    //  },
    //);
  }

  void _addBandToLis(String name) {
    if (name.length > 1) {
      this
          .band
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }

  Widget _bandTitle(Band band) {
    return Dismissible(
      key: Key(band.id),
      onDismissed: (direction) {
        print('Eliminar');
        print(band.id);
      },
      direction: DismissDirection.startToEnd,
      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete Band',
              style: TextStyle(color: Colors.white),
            ),
          )),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => print(band.name),
      ),
    );
  }
}
