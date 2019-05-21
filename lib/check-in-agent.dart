import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:confotor/check-in-list.dart';
import 'package:confotor/confotor-app.dart';
import 'package:confotor/confotor-msg.dart';
import 'package:confotor/ticket.dart';
import 'package:confotor/tickets.dart';

class CheckInObserver {
  final CheckInListItem checkInListItem;
  CheckInObserver(CheckInListItem i): checkInListItem = i;
  static start(CheckInListItem i) {
    return new CheckInObserver(i);
  }
}

class CheckedInTicket extends ConfotorMsg {
  final FoundTicket foundTicket;
  final http.Response res;
  final dynamic error;
  CheckedInTicket({FoundTicket foundTicket, http.Response res, dynamic error}):
    foundTicket = foundTicket,
    res = res,
    error = error;
}

class RequestCheckOutTicket extends ConfotorMsg {
  final FoundTicket foundTicket;
  RequestCheckOutTicket({FoundTicket foundTicket}):
    foundTicket = foundTicket;
}

class CheckInAgent {
  final ConfotorAppState appState;
  final Map<String, CheckInObserver> observers = new Map();

  CheckInAgent({ConfotorAppState appState}): appState = appState;

  CheckInAgent start() {
    this.appState.bus.listen((msg) {
      if (msg is RequestCheckOutTicket) {

      }
      if (msg is FoundTickets) {
        final FoundTickets fts = msg;
        fts.tickets.indexWhere((ft) {
          if (ft.state == FoundTicketState.NeedCheckIn) {
            print('checkIn:${ft.checkInListItem.checkInUrl}:${ft.ticket.id}');
            http.post(ft.checkInListItem.checkInUrl,
              headers: {
                 "Accept": "application/json",
                 "Content-Type": "application/json"
              },
              body: convert.jsonEncode({
                  "checkin": {
                    "ticket_id": ft.ticket.id
                  }
                })
            ).then((res) {
              this.appState.bus.add(CheckedInTicket(foundTicket: ft, res: res));
            }).catchError((e) {
              this.appState.bus.add(CheckedInTicket(foundTicket: ft, error: e));
            });
            return true;
          }
          return false;
        });
      }
  //     curl --request DELETE \
  // --url 'https://checkin.tito.io/checkin_lists/wech/checkins/6e16a93c-df5e-4105-b535-28e029027696' \
  // --header 'Accept: application/json' \
  // --header 'Content-Type: application/json'
      // if (msg is CheckInListsMsg) {
      //   // msg.lists
      //   //   .where((i) => i.ticketsStatus == CheckInListItemTicketsStatus.Fetched)
      //   //   .where((i) => !observers.containsKey(i.url))
      //   //   .forEach((i) {
      //   //     observers.putIfAbsent(i.url, CheckInObserver.start(i));
      //   //   });
      //   observers.values.forEach((cio) {

      //   });

      //   msg.lists.
      //     .where((i) => i.ticketsStatus == CheckInListItemTicketsStatus.Fetched)
      // }

    });
    return this;
  }

}