import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> band = [];

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBand);
  }

  _handleActiveBand(dynamic payload) {
    this.band = (payload as List).map((e) => Band.fomMap(e)).toList();
    setState(() {});
    //Band.fomMap(data);
    //print(data);
  }

  @override
  void dispose() {
    super.dispose();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final estadoSockect = socketService.serverStatus;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'BandName',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: estadoSockect == ServerStatus.EnLiena
                ? Icon(Icons.check_circle, color: Colors.blue)
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: band.length,
              itemBuilder: (BuildContext context, int index) =>
                  _bandTitle(band[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addnewBand,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();

    band.forEach((element) {
      dataMap.putIfAbsent(element.name, () => element.votes.toDouble());
    });

    if (band.length > 0) {
      final List<Color> colorList = [
        Colors.blue[50],
        Colors.blue[200],
        Colors.pink[50],
        Colors.pink[200],
        Colors.yellow[50],
        Colors.yellow[200],
      ];

      return Container(
        padding: EdgeInsets.only(top: 20),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 1.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          centerText: "HYBRID",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _addnewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
        ),
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
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
      // setState(() {});
    }

    Navigator.pop(context);
  }

  Widget _bandTitle(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
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
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }
}
