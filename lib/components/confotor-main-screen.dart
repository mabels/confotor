import 'package:confotor/components/log-list-area.dart';
import 'package:confotor/components/ticket-list-area.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:flutter/material.dart';
import './confotor-app.dart';
import 'active-area.dart';
import 'confotor-drawer.dart';

class ConfotorMainScreen extends StatelessWidget {
  final ConfotorAppState appState;

  const ConfotorMainScreen({@required appState}) : appState = appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Confotor'),
        ),
        drawer: ConfotorDrawer(appState: appState),
        body: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Column(children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                      height: 60.0,
                      color: Colors.blue[50],
                      child: ActionArea(appState: appState)),
                  Container(
                      height: MediaQuery.of(context).size.height - (60 + 100),
                      color: Colors.red[50],
                      child: TicketListArea(appState: appState))
                ])),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    height: 100.0,
                    color: Colors.green[50],
                    child: LogListArea(appState: appState))),
          ],
        ));
  }
}
