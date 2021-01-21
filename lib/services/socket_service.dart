import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { EnLiena, FueraDeLinea, Conectando }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Conectando;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
//
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    // Dart client
    this._socket = IO.io('http://192.168.100.49:3000', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.EnLiena;
      notifyListeners();
    });

    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.FueraDeLinea;
      print('disconnect');
      notifyListeners();
    });

    //_socket.on('nuevo-mensaje', (payload) {
    //  //this._serverStatus = ServerStatus.FueraDeLinea;
    //
    //  print('nuevo-mensaje: $payload');
    //  print('nombre: ' + payload['nombre']);
    //  print(payload.containsKey('mensaje2'));
    //  //notifyListeners();
    //});
  }
}
