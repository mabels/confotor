import 'package:confotor/actions/scan-check-in-list-action.dart';
import 'package:confotor/actions/scan-ticket-action.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:flutter/material.dart';

import 'confotor-app.dart';

class ActionArea extends StatefulWidget {
  final ConfotorAppState _appState;
  ActionArea({ConfotorAppState appState}) : _appState = appState;

  @override
  State<StatefulWidget> createState() {
    return ActionAreaState(appState: _appState);
  }
}

class ActionAreaState extends State<ActionArea> {
  Widget action = Text('No Action');

  ActionAreaState({ConfotorAppState appState}) {
    print('ActionAreaState:ActionAreaState');
    appState.bus.stream.listen((msg) {
      if (msg is ConferencesMsg) {
        setState(() {
          if (msg.conferences.isEmpty) {
            this.action = Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: RaisedButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    splashColor: Colors.redAccent,
                    onPressed: () {
                      scanCheckInListAction(bus: appState.bus);
                    },
                    child: const Text('Add TicketList')));
          } else {
            this.action = RaisedButton(
                color: Colors.pink,
                textColor: Colors.white,
                splashColor: Colors.pinkAccent,
                onPressed: () {
                  scanTicketAction(bus: appState.bus);
                },
                child: const Text('TicketScan'));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: action)
        ]);
  }
}
