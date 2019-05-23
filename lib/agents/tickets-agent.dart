import 'dart:async';
import 'dart:convert' as convert;
import 'dart:ui';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

enum TicketsStatus { Initial, Page, Ready, Error }

class TicketObserver {
  final ConfotorAppState appState;
  final ConferenceKey conference;
  Timer timer;

  // static TicketObserver fetch(
  //     {ConfotorAppState appState, ConferenceKey conference}) {
  //   final tickets = TicketObserver(appState: appState, conference: conference);
  //   tickets.getPages(0);
  //   return tickets;
  // }

  TicketObserver({ConfotorAppState appState, ConferenceKey conference})
      : appState = appState,
        conference = conference;

  getPages(int page, String transaction) {
    final url = this.conference.ticketsUrl(page);
    http.get(url).then((response) {
      if (200 <= response.statusCode && response.statusCode < 300) {
        Iterable jsonResponse = convert.jsonDecode(response.body);
        // this.tickets.addAll(tickets);
        final items = jsonResponse.map((f) => Ticket.fromJson(f));
        this.appState.bus.add(TicketPageMsg(
            transaction: transaction,
            conference: this.conference,
            items: items,
            page: page,
            completed: items.isEmpty));

        if (items.isNotEmpty) {
          getPages(page + 1, transaction);
        }
      } else {
        this.appState.bus.add(TicketsError(
            conference: this.conference, url: url, response: response,
            error: Exception("ResponseCode:getPage:${url}:${response.statusCode}"),
            transaction: transaction));
      }
    }).catchError((e) {
      this.appState.bus.add(
          TicketsError(conference: this.conference, url: url, error: e, transaction: transaction));
    });
  }

  TicketObserver start({int hours = 4}) {
    stop();
    timer = new Timer(Duration(hours: hours), () {
      getPages(1, appState.uuid.v4()); // paged api triggered by page 1
    });
    return this;
  }

  stop() {
    if (timer != null) {
      timer.cancel();
    }
  }
}

// class FoundTicket {
//   final TicketAndCheckIns ticketAndCheckIns;
//   FoundTicket({@required TicketAndCheckIns ticketAndCheckIns}):
//     ticketAndCheckIns = ticketAndCheckIns;

//   get state {
//     if (checkedIns.isEmpty) {
//       return FoundTicketState.Issueable;
//     }
//     return FoundTicketState.Error;
//     // if (checkedIns.last is CheckedTicketError) {
//     //   return FoundTicketState.Error;
//     // }
//     // if (checkedIns.last is CheckedInTicket) {
//     //   return FoundTicketState.CheckedIn;
//     // }
//     // if (checkedIns.last is CheckedOutTicket) {
//     //   return FoundTicketState.CheckedOut;
//     // }
//   }
//   get shortState {
//     return state.toString().split(".").last;
//   }
// }

class TicketsAgent {
  final ConfotorAppState appState;
  final Map<String /* url */, TicketObserver> observers = new Map();

  StreamSubscription subscription;

  TicketsAgent({@required ConfotorAppState appState}) : appState = appState;

  stop() {
    subscription.cancel();
  }

  start() {
    subscription = this.appState.bus.stream.listen((msg) {

      if (msg is AppLifecycleMsg) {
        switch (msg.state) {
          // case AppLifecycleState.inactive:
          case AppLifecycleState.paused:
            observers.values.forEach((o) {
              o.stop();
            });
            break;
          case AppLifecycleState.suspending:
          case AppLifecycleState.resumed:
            observers.values.forEach((o) {
              o.start(hours: 0);
            });
            break;
          case AppLifecycleState.inactive:
            break;
        }
      }
      if (msg is UpdatedConference) {
        if (!observers.containsKey(msg.checkInListItem.url)) {
          observers[msg.checkInListItem.url] = TicketObserver(
              appState: appState, conference: msg.checkInListItem);
          observers[msg.checkInListItem.url].start();
        } 
      }

      if (msg is ConferenceRemoved) {
        if (observers.containsKey(msg.checkInItemMsg.url)) {
          observers[msg.checkInItemMsg.url].stop();
          observers.remove(msg.checkInItemMsg.url);
        }
      }
    });
  }
}

//   if (msg is ConferenceKeysMsg) {
//     msg.conferenceKeys.forEach((i) {
//       if (i.ticketsStatus == CheckInListItemTicketsStatus.Initial) {
//         TicketObserver.fetch(appState: appState, item: i);
//       }
//     });
//     checkInLists.clear();
//     msg.conferences.where((i) => i.ticketsStatus == CheckInListItemTicketsStatus.Fetched).forEach((item) {
//       checkInLists.add(item);
//     });
//   }
//   if (msg is ScanTicketMsg) {
//     ScanTicketMsg tsmsg = msg;
//     final found = findTickets(tsmsg.barcode);
//     this.appState.bus.add(found);
//     print('TicketScanBarcodeMsg:$found');
//   }

//   if (msg is CheckedTicket) {
//     this.lastFoundTickets.where((fts) => fts.hasFound).where((fts) {
//       return fts.tickets.indexWhere((ft) {
//         if (ft.ticket.slug == msg.foundTicket.ticket.slug) {
//           ft.checkedIns.add(msg);
//           return true;
//         }
//         return false;
//       }) >= 0;
//     }).forEach((fts) =>
//       this.appState.bus.add(FoundTickets(tickets: fts.tickets))
//     );
//   }

//   if (msg is FoundTickets) {
//     final idx = this.lastFoundTickets.indexWhere((t) => t.slug == msg.slug);
//     if (idx >= 0) {
//       this.lastFoundTickets.removeAt(idx);
//     }
//     this.lastFoundTickets.insert(0, msg);
//     for(var i = 20; i < lastFoundTickets.length; i++) {
//       lastFoundTickets.removeAt(20);
//     }
//     this.appState.bus.add(LastFoundTickets(last: lastFoundTickets), persist: true);
//   }
// });
