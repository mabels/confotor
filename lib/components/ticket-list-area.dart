import 'dart:async';

import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/msgs/msgs.dart';
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
  final ConfotorAppState appState;
  StreamSubscription subscription;

  TicketListAreaState({ConfotorAppState appState}) : appState = appState;

  @override
  void initState() {
    super.initState();
    print('TicketListAreaState:initState');
    subscription = appState.bus.stream.listen((msg) {
      // print('TicketListAreaState:${msg.runtimeType.toString()}');
      if (msg is LastFoundTickets) {
        setState(() {
          this.lastFoundTickets = msg;
        });
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  actionText(ConferenceTicket tac, String stateText) {
    return Text("${stateText}[${tac.checkInListItem.shortEventTitle}(${tac.ticketAndCheckIns.ticket.reference})]");
  }

  subTitle(FoundTickets foundTickets) {
    return Column(
            children: foundTickets.conferenceTickets.map((foundTicket) {
            switch (foundTicket.ticketAndCheckIns.state) {
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
                        .add(RequestCheckOutTicket(ticket: foundTicket));
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
                        .add(RequestCheckInTicket(ticket: foundTicket));
                  });
                  break;
                default:
                  return RaisedButton(
                  textColor: Colors.white,
                  splashColor: Colors.pinkAccent,
                  child: actionText(foundTicket, foundTicket.ticketAndCheckIns.shortState),
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
