// Copyright (C) 2019 Potix Corporation. All Rights Reserved
// History: 2019-01-21 11:56
// Author: jumperchen<jumperchen@potix.com>
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

void main() {
  var socket = io.io('http://localhost:3000', <String, dynamic>{
    'transports': ['websocket'],
    'extraHeaders': {'foo': 'bar'}
  });
  socket.on('connect', (_) {
    print('connect');
    socket.emit('msg', 'init');
    var count = 0;
    Timer.periodic(const Duration(seconds: 1), (Timer countDownTimer) {
      socket.emit('msg', count++);
    });
  });
  socket.on('event', (data) => print(data));
  socket.on('disconnect', (_) => print('disconnect'));
  socket.on('fromServer', (_) => print(_));
}
