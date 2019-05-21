import 'dart:async';

import 'package:flutter/material.dart';
import './confotor-main-screen.dart';
import './confotor-msg.dart';
import './confotor-drawer.dart';
import './check-in-list.dart';
import './tickets.dart';
import 'package:uuid/uuid.dart';

import 'check-in-agent.dart';

// Stream<ConfotorMsg> stream;
//   @override
//   State<StatefulWidget> createState() {
//     this.stream = confotorStream(context);
//     return null;
//   }

class ConfotorApp extends StatefulWidget {
  @override
  ConfotorAppState createState() => new ConfotorAppState();
}

class ConfotorBus {
  StreamController<ConfotorMsg> bus = new StreamController();
  Stream<ConfotorMsg> _stream;
  Map<String, ConfotorMsg> persistMsgs = new Map();

  ConfotorBus() {
    print('Switch BroadcastStream');
    this._stream = this.bus.stream.asBroadcastStream();
  }

  add(ConfotorMsg msg, { bool persist = false }) {
    if (persist) {
      persistMsgs[msg.runtimeType.toString()] = msg;
    }
    this.bus.add(msg);
  }

  Stream<ConfotorMsg> get stream {
    StreamController<ConfotorMsg> ctl;
    ctl = StreamController(onListen: () {
      this.persistMsgs.values.forEach((msg) => ctl.add(msg));
    });
    this._stream.listen((msg) => ctl.add(msg),
      onDone: () => ctl.close(),
      onError: (e) => ctl.addError(e),
    );
    return ctl.stream.asBroadcastStream();
  }

  listen(void onData(ConfotorMsg event)) {
    print('Listen:1');
    var ret = this.stream.listen(onData);
    print('Listen:2');
    return ret;
  }

  // Stream<ConfotorMsg> get stream {
  //   print('CreateNewStream:1');
  //   final ret = new StreamController<ConfotorMsg>();
  //   print('CreateNewStream:2');
  //   this.bus.stream.listen((msg) {
  //     ret.add(msg);
  //   });
  //   print('CreateNewStream:3');
  //   return ret.stream;
  // }

}

class ConfotorAppState extends State<ConfotorApp> {
  final uuid = new Uuid();
  ConfotorBus bus;
  CheckInListAgent checkInListAgent;
  TicketsAgent ticketsAgent;
  CheckInAgent checkInAgent;
  // Drawer drawer;
  @override
  initState() {
    super.initState();
    this.bus = new ConfotorBus();
    this.checkInListAgent = new CheckInListAgent(appState: this).start();
    this.ticketsAgent = new TicketsAgent(appState: this).start();
    this.checkInAgent = new CheckInAgent(appState: this).start();
    // this.drawer = confotorDrawer(appState: this);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Confotor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConfotorMainScreen(appState: this)
    );
  }
}