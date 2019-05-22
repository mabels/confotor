import 'package:confotor/components/ticket-list-area.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:flutter/material.dart';
import './confotor-app.dart';
import 'active-area.dart';
import 'confotor-drawer.dart';

logArea({ConfotorAppState appState}) {
  return StreamBuilder(
      stream: appState.bus.stream,
      builder: (BuildContext context, AsyncSnapshot<ConfotorMsg> snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[Text(snapshot.data.runtimeType.toString())],
        );
      });
}

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                height: 60.0,
                color: Colors.blue[50],
                alignment: Alignment.topCenter,
                child: ActionArea(appState: appState)),
            Container(
                height: 300.0,
                color: Colors.red[50],
                alignment: Alignment.topCenter,
                child: TicketListArea(appState: appState)),
            Container(
                height: 40.0,
                color: Colors.green[50],
                alignment: Alignment(-0.9, -0.9),
                child: logArea(appState: appState)),
          ],
        ));
  }
}
