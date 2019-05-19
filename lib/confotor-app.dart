import 'dart:async';

import 'package:flutter/material.dart';
import './confotor-main-screen.dart';
import './confotor-msg.dart';
import './confotor-drawer.dart';
import './check-in-list.dart';
import './tickets.dart';
import 'package:uuid/uuid.dart';

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
  Stream<ConfotorMsg> stream;

  ConfotorBus() {
    print('Switch BroadcastStream');
    this.stream = this.bus.stream.asBroadcastStream();
  }

  add(ConfotorMsg msg) {
    this.bus.add(msg);
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
  Drawer drawer;
  @override
  initState() {
    super.initState();
    this.bus = new ConfotorBus();
    this.checkInListAgent = new CheckInListAgent(appState: this).start();
    this.ticketsAgent = new TicketsAgent(appState: this).start();
    this.drawer = confotorDrawer(appState: this);
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