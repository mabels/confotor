import 'package:confotor/tickets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'confotor-app.dart';

class TicketListArea extends StatefulWidget {
  final ConfotorAppState _appState;
  TicketListArea({ConfotorAppState appState}) : _appState = appState;

  @override
  State<StatefulWidget> createState() {
    return TicketListAreaState(appState: _appState);
  }
}

class TicketListAreaState extends State<TicketListArea> {
  LastFoundTickets lastFoundTickets;

  TicketListAreaState({ConfotorAppState appState}) {
    print('TicketListAreaState:TicketListAreaState');
    appState.bus.stream.listen((msg) {
      print('TicketListAreaState:${msg.runtimeType.toString()}');
      if (msg is LastFoundTickets) {
        setState(() {
          this.lastFoundTickets = msg;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Build:${lastFoundTickets}');
    if (lastFoundTickets == null) {
      return ListView(children: <Widget>[]);
    } else {
      print('Build:${lastFoundTickets.last.length}');
      return ListView(
          children: lastFoundTickets.last
              .map((foundTickets) {
                return ListTile(
                      key: Key(foundTickets.slug),
                      title: Text(foundTickets.name),
                      subtitle: Text(foundTickets.tickets.map((foundTicket) {
                        return foundTicket.checkInListItem.shortEventTitle;
                      }).join("/"))
                );
              }).toList());
    }
  }
}
