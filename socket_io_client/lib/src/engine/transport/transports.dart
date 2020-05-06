/**
 * transports.dart
 *
 * Purpose:
 *
 * Description:
 *
 * History:
 *   26/04/2017, Created by jumperchen
 *
 * Copyright (C) 2017 Potix Corporation. All Rights Reserved.
 */

import 'package:socket_io_client/src/engine/transport/jsonp_transport.dart';
import 'package:socket_io_client/src/engine/transport/transport.dart';
import 'package:socket_io_client/src/engine/transport/websocket_transport.dart';
import 'package:socket_io_client/src/engine/transport/xhr_transport.dart';

class Transports {
  static List<String> upgradesTo(String from) {
    if ('polling' == from) {
      return ['websocket'];
    }
    return [];
  }

  static Transport newInstance(String name, options) {
    if ('websocket' == name) {
      return WebSocketTransport(options);
    } else if ('polling' == name) {
      if (options['forceJSONP'] != true) {
        return XHRTransport(options);
      } else {
        if (options['jsonp'] != false) return JSONPTransport(options);
        throw StateError('JSONP disabled');
      }
    } else {
      throw UnsupportedError('Unknown transport $name');
    }
  }
}
