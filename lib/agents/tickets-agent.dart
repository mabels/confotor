import 'dart:ui';

import 'package:confotor/agents/ticket-observer.dart';
import 'package:confotor/models/conference.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';


class Transaction<T> {
  String transaction;
  final T value;
  Transaction({
    @required T value,
    String transaction
  }): value = value, transaction = transaction;
}

class TicketsAgent {
  final ConfotorAppState _appState;
  final BaseClient _client;
  final List<Transaction<TicketObserver>> observers = List();

  // StreamSubscription subscription;

  TicketsAgent({
    @required ConfotorAppState appState,
    BaseClient client}) : _appState = appState, _client = client;

  stop() {
    // subscription.cancel();
  }

  TicketsAgent start() {
    // print('TicketAgent:start');
    reaction((_) => _appState.appLifecycleAgent.state, (state) {
      switch (state) {
        // case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
          observers.forEach((o) {
            o.value.stop();
          });
          break;
        case AppLifecycleState.suspending:
        case AppLifecycleState.resumed:
          observers.forEach((o) {
            o.value.start(hours: 0);
          });
          break;
        case AppLifecycleState.inactive:
          break;
      }
    });
    reaction<Iterable<Conference>>((_) => _appState.conferencesAgent.conferences.values, (vs) {
      final transaction = _appState.uuid.v4();
      final List<Conference> confs = List.from(vs);
      observers.forEach((obs) {
        final preLength = confs.length;
        confs.removeWhere((i) => obs.value.url == i.url); 
        if (preLength != confs.length) {
          // print('restart:${obs.value.url}');
          obs.transaction = transaction;
          obs.value.start(); // restart
        }
      });
      confs.forEach((conf) {
        // print('start:${conf.url}');
        observers.add(Transaction(transaction: transaction, 
          value: TicketObserver(appState: _appState, 
            conference: conf,
            client: _client
          ).start()));
      });
      // remove unsed
      observers.removeWhere((o) => o.transaction != transaction);
    }, fireImmediately: true);
    return this;
  }

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
