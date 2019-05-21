import 'package:confotor/tickets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'check-in-agent.dart';
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
  final ConfotorAppState appState;

  TicketListAreaState({ConfotorAppState appState}) : appState = appState {
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
          children: lastFoundTickets.last.map((foundTickets) {
        if (foundTickets.hasFound) {
          final subTitle = Column(
            children: foundTickets.tickets.map((foundTicket) {
                final List<Widget> out = [];
                if (foundTicket.state == FoundTicketState.CheckedIn) {
                  out.add(RaisedButton(
                    color: Colors.pink,
                    textColor: Colors.white,
                    splashColor: Colors.pinkAccent,
                    onPressed: () {
                      this.appState.bus.add(RequestCheckOutTicket(foundTicket: foundTicket));
                      // ticketScan(bus: appState.bus);
                    },
                  child: Text("CheckOut[${foundTicket.checkInListItem.shortEventTitle}(${foundTicket.ticket.reference})]")));
                } else {
                  out.add(
                      Text("[${foundTicket.shortState}] -- ${foundTicket.checkInListItem.shortEventTitle}(${foundTicket.ticket.reference})")
                  );
                }
                return Column(children: out);
              }).toList()
          );
          return ListTile(
              key: Key(foundTickets.slug),
              title: Text(foundTickets.name),
              subtitle: subTitle
          );
        } else {
          return ListTile(
              title: Container(color: Colors.red, child: Text("No Ticket found from Scan")));
        }
      }).toList());
    }
  }
}
