import 'dart:async';

import 'package:confotor/models/found-tickets.dart';
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
  Timer timer;
  int checkoutPressCounter = 0;

  TicketListAreaState({ConfotorAppState appState}) : appState = appState;

  @override
  void initState() {
    super.initState();
    // print('TicketListAreaState:initState');
    subscription = appState.bus.stream.listen((msg) {
      if (msg is LastFoundTickets) {
        //  print('LastFoundTickets:CloseQrScan:${json.encode(msg.last.first.conferenceTickets.first.ticketAndCheckIns.checkInItems)}');
        print('LastFoundTickets:Redraw');
        // appState.bus.add(CloseQrScan());
        setState(() {
          lastFoundTickets = msg;
        });
      }
      if (msg is SelectLane) {
        setState(() {
          appState.lane = msg.lane;
        });
      }
    });
    appState.bus.add(RequestLastFoundTickets());
    timer = Timer.periodic(Duration(milliseconds: 1500), (_) => checkoutPressCounter = 0);
  }

  @override
  dispose() {
    super.dispose();
    timer.cancel();
    subscription.cancel();
  }

  actionText(ConferenceTicket tac, String stateText) {
    switch (tac.checkInList.shortEventTitle) {
      case 'CSSconf':
        return Column(children: [
          //Image.asset('assets/cssconf.png', height: 60),
          // SvgPicture.asset('assets/jsconf.svg',
          //     semanticsLabel: tac.checkInList.shortEventTitle),
          Text(
              "CSSconf EU ${stateText} [${tac.ticketAndCheckIns.ticket.reference}]")
        ]);
      case 'JSConf':
        return Column(children: [
          //Image.asset('assets/jsconf.png', height: 60),
          // SvgPicture.asset('assets/jsconf.svg',
          //     semanticsLabel: tac.checkInList.shortEventTitle),
          Text(
              "JSConf EU ${stateText} [${tac.ticketAndCheckIns.ticket.reference}]")
        ]);
      default:
        return Text(
            "${stateText}[${tac.checkInList.shortEventTitle}(${tac.ticketAndCheckIns.ticket.reference})]");
    }
  }

  subTitle(FoundTickets foundTickets) {
    return Column(
        children: foundTickets.conferenceTickets
            .map((conferenceTicket) {
              if (conferenceTicket.runningAction) {
                return RaisedButton(
                    textColor: Colors.white,
                    splashColor: Colors.pinkAccent,
                    child: actionText(conferenceTicket, "Running"),
                    color: Colors.pink,
                    onPressed: () {});
              }
              switch (conferenceTicket.state) {
                case TicketAndCheckInsState.Used:
                  if (conferenceTicket.issuedFromMe) {
                    return RaisedButton(
                        textColor: Colors.white,
                        splashColor: Colors.pinkAccent,
                        child: actionText(
                            conferenceTicket, "checked in successfully "),
                        color: Colors.green,
                        onPressed: () {
                          this.appState.bus.add(
                              RequestCheckOutTicket(ticket: conferenceTicket));
                        });
                  } else {
                    return RaisedButton(
                        textColor: Colors.white,
                        splashColor: Colors.pinkAccent,
                        child: actionText(conferenceTicket, "is already used "),
                        color: Colors.red,
                        onPressed: () {
                          if (++checkoutPressCounter % 5 == 0) {
                            this.appState.bus.add(RequestCheckOutTicket(
                                ticket: conferenceTicket));
                          }
                        });
                  }
                  break;

                // case TicketAndCheckInsState.Issued:
                //   return RaisedButton(
                //       textColor: Colors.white,
                //       splashColor: Colors.pinkAccent,
                //       child: actionText(conferenceTicket, "Ticket is checked in"),
                //       color: Colors.green,
                //       onPressed: () {
                //         this
                //             .appState
                //             .bus
                //             .add(RequestCheckOutTicket(ticket: conferenceTicket));
                //       });
                //   break;

                case TicketAndCheckInsState.Issueable:
                  return RaisedButton(
                      textColor: Colors.white,
                      splashColor: Colors.pinkAccent,
                      child: actionText(
                          conferenceTicket, "Ticket is not checked in"),
                      color: Colors.blue,
                      onPressed: () {
                        this.appState.bus.add(
                            RequestCheckInTicket(ticket: conferenceTicket));
                      });
                  break;
                default:
                  return RaisedButton(
                      textColor: Colors.white,
                      splashColor: Colors.pinkAccent,
                      child: actionText(
                          conferenceTicket, conferenceTicket.shortState),
                      color: Colors.purple);
                  break;
              }
            })
            .map((p) => Padding(padding: EdgeInsets.all(3), child: p))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> withLane = [];
    if (appState.lane != null) {
      withLane.add(Card(
              color: Colors.white,
              child: ListTile(
                  title: Text('Lane ${appState.lane.start}-${appState.lane.end}',
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Color(0xFF303f62),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center))));
    }
    // print('Build:${lastFoundTickets}');
    if (lastFoundTickets == null) {
      return ListView(children: <Widget>[]);
    } else {
      // print('Build:${lastFoundTickets.last.length}');
      withLane.addAll(lastFoundTickets.last.map((foundTickets) {
        if (foundTickets.hasFound) {
          return Card(
              color: Colors.white70,
              child: ListTile(
                  title: Text(foundTickets.name,
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Color(0xFF303f62),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  subtitle: subTitle(foundTickets)));
        } else {
          return Card(
              color: Colors.red,
              child: ListTile(
                  title: Container(
                      color: Colors.red,
                      child: Text("No Ticket found from Scan[${foundTickets.scan}]"))));
        }
      }));
      return ListView(
          children: withLane
      );
    }
  }
}
