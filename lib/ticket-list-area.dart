import 'package:confotor/ticket-and-checkins.dart';
import 'package:confotor/tickets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'check-in-agent.dart';
import 'check-in-list.dart';
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
      // print('TicketListAreaState:${msg.runtimeType.toString()}');
      if (msg is LastFoundTickets) {
        setState(() {
          this.lastFoundTickets = msg;
        });
      }
    });
  }

  actionText(TicketAndCheckIns tac, String stateText) {
    return Text("${stateText}[${tac.checkInListItem.shortEventTitle}(${tac.ticket.reference})]");
  }

  subTitle(FoundTickets foundTickets) {
    return Column(
            children: foundTickets.tickets.map((foundTicket) {
            switch (foundTicket.state) {
                case TicketAndCheckInsState.Used:
                  return RaisedButton(
                  textColor: Colors.white,
                  splashColor: Colors.pinkAccent,
                  child: actionText(foundTicket, "TicketUsed"),
                  color: Colors.red);
                  break;

                case TicketAndCheckInsState.Issued:
                  return RaisedButton(
                  textColor: Colors.white,
                  splashColor: Colors.pinkAccent,
                  child: actionText(foundTicket, "Checkout"),
                  color: Colors.green,
                  onPressed: () {
                    this
                        .appState
                        .bus
                        .add(RequestCheckOutTicket(foundTicket: foundTicket));
                  });
                  break;

                case TicketAndCheckInsState.Issueable:
                  return RaisedButton(
                  textColor: Colors.white,
                  splashColor: Colors.pinkAccent,
                  child: actionText(foundTicket, "Checkin"),
                  color: Colors.blue,
                  onPressed: () {
                    this
                        .appState
                        .bus
                        .add(RequestCheckInTicket(foundTicket: foundTicket));
                  });
                  break;
                default:
                  return RaisedButton(
                  textColor: Colors.white,
                  splashColor: Colors.pinkAccent,
                  child: actionText(foundTicket, foundTicket.shortState),
                  color: Colors.purple);
                  break;
              }
            }).toList()
    );
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
          return ListTile(
            key: Key(foundTickets.slug),
            title: Text(foundTickets.name),
            subtitle: subTitle(foundTickets)
          );
        } else {
          return ListTile(
            title: Container(
            color: Colors.red, child: Text("No Ticket found from Scan")));
        }
        }).toList()
      );
    }
  }
}
