import 'dart:async';
import 'dart:convert' as convert;
import 'dart:ui';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

enum TicketsStatus { Initial, Page, Ready, Error }

class TicketObserver {
  final ConfotorAppState appState;
  // final Observable<CheckInList> checkInList;
  Timer timer;

  // static TicketObserver fetch(
  //     {ConfotorAppState appState, ConferenceKey conference}) {
  //   final tickets = TicketObserver(appState: appState, conference: conference);
  //   tickets.getPages(0);
  //   return tickets;
  // }

  TicketObserver({ConfotorAppState appState}) : appState = appState;
        // checkInList = checkInList;

  getPages(int page, String transaction) {
    final url = this.checkInList.ticketsUrl(page);
    print('TicketAgent:getPages:$url:$page:$transaction');
    http.get(url).then((response) {
      print('TicketAgent:getPages:$url:$page:$transaction:${response.statusCode}');
      if (200 <= response.statusCode && response.statusCode < 300) {
        Iterable jsonResponse = convert.jsonDecode(response.body);
        // this.tickets.addAll(tickets);
        final items = jsonResponse.map((f) => Ticket.fromJson(f));
        this.appState.bus.add(TicketPageMsg(
            transaction: transaction,
            checkInList: this.checkInList,
            items: items.toList(),
            page: page,
            completed: items.isEmpty));

        if (items.isNotEmpty) {
          getPages(page + 1, transaction);
        }
      } else {
        print("TicketsError:ResponseCode:getPage:${url}:${response.statusCode}");
        this.appState.bus.add(TicketsError(
            conference: this.checkInList, url: url, response: response,
            error: Exception("ResponseCode:getPage:${url}:${response.statusCode}"),
            transaction: transaction));
      }
    }).catchError((e) {
      print("TicketsError:ResponseCode:getPage:${url}:${e}");
      this.appState.bus.add(
          TicketsError(conference: this.checkInList, url: url, error: e, transaction: transaction));
    });
  }

  TicketObserver start({int hours = 4}) {
    stop();
    print('TicketObserver:start:$hours');
    timer = new Timer(Duration(hours: hours), () {
      print('TicketObserver:start:$hours:getPages:');
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
  final Map<String /* url */, TicketObserver> observers = Map();

  // StreamSubscription subscription;

  TicketsAgent({@required ConfotorAppState appState}) : appState = appState;

  stop() {
    // subscription.cancel();
  }

  start() {
    print('TicketAgent:start');
    appState.appLifecycleAgent.action((state) {
        switch (state) {
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
  });

  // appState.checkInListAgent.



  //     if (msg is UpdatedConference) {
  //       // print('TicketsAgent:UpdatedConference:${msg.checkInList.url}');
  //       if (!observers.containsKey(msg.checkInList.url)) {
  //         // print('TicketsAgent:UpdatedConference:${msg.checkInList.url}:create');
  //         observers[msg.checkInList.url] = TicketObserver(
  //             appState: appState, checkInList: msg.checkInList);
  //         observers[msg.checkInList.url].start(hours: 0);
  //       }
  //     }

  //     if (msg is RemovedConference) {
  //       if (observers.containsKey(msg.checkInList.url)) {
  //         observers[msg.checkInList.url].stop();
  //         observers.remove(msg.checkInList.url);
  //       }
  //     }
  //   });
  // }
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
