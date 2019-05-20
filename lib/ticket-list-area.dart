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
  ActiveFoundTickets activeFoundTickets;

  TicketListAreaState({ConfotorAppState appState}) {
    print('TicketListAreaState:TicketListAreaState');
    appState.bus.stream.listen((msg) {
      print('TicketListAreaState:${msg.runtimeType.toString()}');
      if (msg is ActiveFoundTickets) {
        setState(() {
          this.activeFoundTickets = msg;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Build:${activeFoundTickets}');
    if (activeFoundTickets == null) {
      return ListView(children: <Widget>[]);
    } else {
      print('Build:${activeFoundTickets.active.length}');
      return ListView(
          children: activeFoundTickets.active
              .map((foundTickets) {
                print('Build:X:${activeFoundTickets.active.length}:${foundTickets.tickets.length}');
                return foundTickets.tickets.map((foundTicket) {
                  print('Build:Y:${activeFoundTickets.active.length}:${foundTicket.ticket.slug}');
                  return ListTile(
                      key: Key(foundTicket.ticket.slug),
                      title: Text(
                          "${foundTicket.ticket.first_name} ${foundTicket.ticket.last_name}"),
                      subtitle: Text(
                          "${foundTicket.tickets.checkInListItem.event_title}:${foundTicket.ticket.email}"));
                }).toList();
              })
              .expand((i) => i)
              .toList());
    }
  }
}
