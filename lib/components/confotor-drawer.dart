import 'package:confotor/actions/scan-check-in-list-action.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:flutter/material.dart';
import './confotor-app.dart';
// import 'confotor-msg.dart';

List<Widget> staticDrawer({ConfotorAppState appState}) {
  return [
    ListTile(
        key: Key('AddCheckInList'),
        title: Text('Add Check-In List'),
        onTap: () {
          scanCheckInListAction(bus: appState.bus);
        })
  ];
}

refreshSection({
  ConfotorAppState appState,
  List<Widget> drawer,
  List<Conference> confs}) {
  List<Widget> children = [];
  if (confs.isNotEmpty) {
    children.add(ListTile(
        key: Key('RefreshTickets'),
        title: Text('Refresh Tickets'),
        onTap: () {
          confs.forEach((conf) => appState.bus.add(RequestUpdateConference(checkInListItem: conf.checkInList)));
        }));
         confs.forEach((conf) => children.add(ListTile(
          key: Key(conf.checkInList.url),
          title: Text("${conf.checkInList.event_title}(${conf.ticketAndCheckInsList.length}-${conf.checkInItemLength})"),
          onTap: () {
            appState.bus.add(RequestUpdateConference(checkInListItem: conf.checkInList));
          })));
  }
  drawer.add(Column(
    children: children
  ));
}

removeSection({
  ConfotorAppState appState,
  List<Widget> drawer,
  List<Conference> confs}) {
  List<Widget> children = [];
  if (confs.isNotEmpty) {
    children.add(ListTile(
        key: Key('RemoveTickets'),
        title: Text('Remove Tickets'),
        onLongPress: () {
          // Navigator.of(appState.context).pop();
          // checkInListScan(bus: appState.bus);
          confs.forEach((conf) => appState.bus.add(RequestRemoveConference(conference: conf.checkInList)));
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (BuildContext context) => ScanScreen()));
        }));
        confs.forEach((conf) => children.add(ListTile(
          key: Key(conf.checkInList.url),
          title: Text("${conf.checkInList.event_title}(${conf.ticketAndCheckInsList.length}-${conf.checkInItemLength})"),
          onLongPress: () {
            appState.bus.add(RequestRemoveConference(conference: conf.checkInList));
          })));

    // children.add(Column(
    //     children: [ListView(
    //     children:
    //         title: Text(item.event_title),
    //         onTap: () {
    //           appState.bus.add(new CheckInListItemRemove(item: item));

    //         }
    //       )).toList()
    //   )]));
  }
  drawer.add(Column(
    children: children
  ));
}

class ConfotorDrawer extends StatefulWidget {
  final ConfotorAppState _appState;

  ConfotorDrawer({ConfotorAppState appState}) : _appState = appState;

  @override
  State<StatefulWidget> createState() {
    return ConfotorDrawerState(appState: _appState);
  }
}

class ConfotorDrawerState extends State<ConfotorDrawer> {
  final ConfotorAppState appState;
  List<Widget> items;

  ConfotorDrawerState({ConfotorAppState appState}): appState = appState {
    items = staticDrawer(appState: appState);
  }

  @override
  void initState() {
    super.initState();
    appState.bus.stream.listen((msg) {
      if (msg is Conferences) {
          final drawer = staticDrawer(appState: appState);
          refreshSection(appState: appState, drawer: drawer, confs: msg.conferences);
          removeSection(appState: appState, drawer: drawer, confs: msg.conferences);
          setState(() {
            items = drawer;
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(children: items));
  }
}