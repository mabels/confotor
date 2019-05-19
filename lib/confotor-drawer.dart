
import 'package:flutter/material.dart';
import './confotor-app.dart';
import './check-in-list.dart';

confotorDrawer({ConfotorAppState appState}) {
  final drawer = Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                key: Key('AddCheckInList'),
                title: Text('Add Check-In List'),
                onTap: () {
                  // Navigator.of(appState.context).pop();
                  checkInListScan(bus: appState.bus);
                  // Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (BuildContext context) => ScanScreen()));
                }
              ),
              ListTile(
                key: Key('Refresh Tickets'),
                title: Text('Refresh Tickets'),
                onTap: () {
                  appState.bus.add(new ClickInListsRefresh());
                }
              )
            ],
            ),
  );
  return drawer;
}