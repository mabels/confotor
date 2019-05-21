import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import './confotor-app.dart';
import './check-in-list.dart';
// import 'confotor-msg.dart';

List<Widget> staticDrawer({ConfotorAppState appState}) {
  return [
    ListTile(
        key: Key('AddCheckInList'),
        title: Text('Add Check-In List'),
        onTap: () {
          checkInListScan(bus: appState.bus);
        })
  ];
}

refreshSection({
  ConfotorAppState appState,
  List<Widget> drawer,
  List<CheckInListItem> lists}) {
  List<Widget> children = [];
  if (lists.isNotEmpty) {
    children.add(ListTile(
        key: Key('RefreshTickets'),
        title: Text('Refresh Tickets'),
        onTap: () {
          appState.bus.add(new ClickInListsRefresh());
        }));
         lists.forEach((item) => children.add(ListTile(
          key: Key(item.event_title),
          title: Text("${item.event_title}(${item.ticketsCount})"),
          onTap: () {
            appState.bus.add(new ClickInListsRefresh(items: [item]));
          })));
  }
  drawer.add(Column(
    children: children
  ));
}

removeSection({
  ConfotorAppState appState,
  List<Widget> drawer,
  List<CheckInListItem> lists}) {
  List<Widget> children = [];
  if (lists.isNotEmpty) {
    children.add(ListTile(
        key: Key('RemoveTickets'),
        title: Text('Remove Tickets'),
        onLongPress: () {
          // Navigator.of(appState.context).pop();
          // checkInListScan(bus: appState.bus);
          appState.bus.add(new CheckInListsRemove(items: lists));
          // Navigator.of(context).push(MaterialPageRoute(
          //   builder: (BuildContext context) => ScanScreen()));
        }));
        lists.forEach((item) => children.add(ListTile(
          key: Key(item.event_title),
          title: Text("${item.event_title}(${item.ticketsCount})"),
          onLongPress: () {
            appState.bus.add(new CheckInListsRemove(items: [item]));
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
  Widget item;

  ConfotorDrawerState({ConfotorAppState appState}) {
    item = ListView(children: staticDrawer(appState: appState));
    appState.bus.stream.listen((msg) {
      if (msg is CheckInListsMsg) {
          final CheckInListsMsg ret = msg;
          final drawer = staticDrawer(appState: appState);
          refreshSection(appState: appState, drawer: drawer, lists: ret.lists);
          removeSection(appState: appState, drawer: drawer, lists: ret.lists);
          setState(() {
            item = ListView(children: drawer);
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: item);
  }
}