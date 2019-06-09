// import 'package:confotor/actions/scan-check-in-list-action.dart';
import 'dart:async';

import 'package:confotor/models/conferences.dart';
import 'package:confotor/models/lane.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../confotor-appstate.dart';
import './confotor-app.dart';
// import 'confotor-msg.dart';

class ConfotorDrawer extends StatefulWidget {
  final ConfotorAppState _appState;

  ConfotorDrawer({ConfotorAppState appState}) : _appState = appState;

  @override
  State<StatefulWidget> createState() {
    return ConfotorDrawerState(appState: _appState);
  }
}

final List<Lane> lanes = [
  Lane('a-c'),
  Lane('d-h'),
  Lane('i-k'),
  Lane('l-m'),
  Lane('n-r'),
  Lane('s-z')
];

class ConfotorDrawerState extends State<ConfotorDrawer> {
  final ConfotorAppState appState;
  // StreamSubscription subscription;

  ConfotorDrawerState({ConfotorAppState appState}) : appState = appState;

  _refreshSection(
      {ConfotorAppState appState, List<Widget> drawer, Conferences confs}) {
    List<Widget> children = [];

    if (appState.conferencesAgent.conferences.isNotEmpty) {
      children.add(ListTile(
          key: Key('RefreshTickets'),
          title: Text('Refresh Tickets',
              style: TextStyle(color: Colors.deepOrange)),
          onTap: () {
            confs.values.forEach((conf) => appState.bus
                .add(RequestUpdateConference(checkInList: conf.checkInList)));
          }));
      confs.values.forEach((conf) => children.add(ListTile(
          key: Key(conf.checkInList.url),
          title: Text(
              "${conf.checkInList.item.eventTitle}(${conf.ticketAndCheckInsLength}-${conf.checkInItemLength})",
              style: TextStyle(color: Colors.deepOrange)),
          onTap: () {
            appState.bus
                .add(RequestUpdateConference(checkInList: conf.checkInList));
          })));
    }
    drawer.add(Column(children: children));
  }

  _removeSection(
      {ConfotorAppState appState, List<Widget> drawer, Conferences confs}) {
    List<Widget> children = [];
    if (confs.isNotEmpty) {
      children.add(ListTile(
          key: Key('RemoveTickets'),
          title: Text('Remove Tickets',
              style: TextStyle(color: Colors.deepOrange)),
          onLongPress: () {
            // Navigator.of(appState.context).pop();
            // checkInListScan(bus: appState.bus);
            confs.values.forEach((conf) => appState.bus
                .add(RequestRemoveConference(conference: conf.checkInList)));
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (BuildContext context) => ScanScreen()));
          }));
      confs.values.forEach((conf) => children.add(ListTile(
          key: Key(conf.checkInList.url),
          title: Text(
              "${conf.checkInList.item.eventTitle}(${conf.ticketAndCheckInsLength}-${conf.checkInItemLength})",
              style: TextStyle(color: Colors.deepOrange)),
          onLongPress: () {
            appState.bus
                .add(RequestRemoveConference(conference: conf.checkInList));
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
    drawer.add(Column(children: children));
  }

  List<Widget> _staticDrawer(
      {@required ConfotorAppState appState, Lane selectedLane}) {
    final List<Widget> ret = [
      ListTile(
          key: Key('Reset Last TicketList'),
          title: Text('Reset Last TicketList',
              style: TextStyle(color: Colors.deepOrange)),
          onTap: () {
            appState.bus.add(ResetLastFoundTickets());
          }),
      ListTile(
          key: Key('Ambiguous TicketList'),
          title: Text('Ambiguous TicketList',
              style: TextStyle(color: Colors.deepOrange)),
          onTap: () {
            appState.bus.add(RequestAmbiguousLastFoundTickets());
          }),
      // ListTile(
      // key: Key('Reset Lane'),
      // title: Text('Reset Lane',
      //   style: TextStyle(color: Colors.deepOrange)),
      // onTap: () {
      //   appState.bus.add(SelectLane());
      // })
      // ListTile(
      //     key: Key('AddCheckInList'),
      //     title: Text('Add Check-In List',
      //       style: TextStyle(color: Colors.deepOrange)),
      //     onTap: () {
      //       scanCheckInListAction(bus: appState.bus);
      //     })
    ];
    lanes.forEach((lane) {
      ret.add(ListTile(
          key: Key('Lane ${lane.toString()}'),
          title: Text('Lane ${lane.toString()}',
              style: TextStyle(
                  color:
                      lane != selectedLane ? Colors.deepOrange : Colors.white)),
          onTap: () {
            appState.bus
                .add(SelectLane(lane: lane == selectedLane ? null : lane));
          }));
    });
    return ret;
  }

  @override
  void initState() {
    super.initState();
    // subscription = appState.bus.stream.listen((msg) {
    //   if (msg is ConferencesMsg) {
    //     print('Conferences:${msg.conferences.conferences.length}');
    //     setState(() {
    //       conferences = msg.conferences;
    //     });
    //   }
    //   if (msg is SelectLane) {
    //     setState(() {});
    //   }
    // });
    // appState.bus.add(RequestConferencesMsg());
  }

  @override
  void dispose() {
    super.dispose();
    // subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
            color: Color(0xFF303f62),
            child: Observer(builder: (_) {
              final items = _staticDrawer(
                  appState: appState, selectedLane: appState.lane);
              final conferences = appState.conferencesAgent.conferences;
              _refreshSection(
                  appState: appState, drawer: items, confs: conferences);
              _removeSection(
                  appState: appState, drawer: items, confs: conferences);
              return ListView(children: items);
            })));
  }
}
