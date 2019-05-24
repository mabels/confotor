import 'package:confotor/msgs/confotor-msg.dart';
import 'package:flutter/material.dart';

import 'confotor-app.dart';

class LogListArea extends StatefulWidget {
  final ConfotorAppState _appState;
  LogListArea({ConfotorAppState appState}) : _appState = appState;

  @override
  State<StatefulWidget> createState() {
    return LogListAreaState(appState: _appState);
  }
}

class LogListAreaState extends State<LogListArea> {
  final List<ConfotorMsg> logList = [];
  final ConfotorAppState appState;

  LogListAreaState({ConfotorAppState appState}) : appState = appState;

  @override
  void initState() {
    super.initState();
    appState.bus.stream.listen((msg) {
      // print('TicketListAreaState:${msg.runtimeType.toString()}');
      if (msg is ConfotorMsg) {
        setState(() {
          this.logList.insert(0, msg);
          for (int len = 10; len < this.logList.length; ++len) {
            this.logList.removeLast();
          }
        });
      }
    });
  }

    @override
  Widget build(BuildContext context) {
      return ListView(
        children: logList.map((cmsg) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          title: Text(cmsg.runtimeType.toString())
        )).toList()
      );
  }


}