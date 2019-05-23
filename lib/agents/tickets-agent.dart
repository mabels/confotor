import 'dart:async';
import 'dart:convert' as convert;

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:http/http.dart' as http;

enum TicketsStatus { Initial, Page, Ready, Error }

class TicketsPages {
  final ConfotorAppState appState;
  final String transaction;
  final CheckInListItem checkInListItem;

  static TicketsPages fetch({ConfotorAppState appState, CheckInListItem checkInListItem}) {
    final tickets = TicketsPages(appState: appState, checkInListItem: checkInListItem);
    tickets.getPages(0);
    return tickets;
  }

  TicketsPages({ConfotorAppState appState, CheckInListItem checkInListItem})
    : transaction = appState.uuid.v4(),
      appState = appState,
      checkInListItem = checkInListItem;

  getPages(int page) {
    final url = this.checkInListItem.ticketsUrl(page);
    print("getPage:$url");
    http.get(url).then((response) {
      if (200 <= response.statusCode && response.statusCode < 300) {
        Iterable jsonResponse = convert.jsonDecode(response.body);
        Map<int, Ticket> tickets = new Map();
        jsonResponse.forEach((f) {
          Ticket ticket = Ticket.fromJson(f);
          tickets[ticket.id] = ticket;
        });
        // this.tickets.addAll(tickets);
        this.appState.bus.add(TicketsPageMsg(
            transaction: transaction,
            conferenceKey: this.checkInListItem,
            tickets: tickets,
            page: page,
            completed: page >= this.checkInListItem.total_pages));
        if (page < this.checkInListItem.total_pages) {
          getPages(page + 1);
        }
      } else {
        this.appState.bus.add(new TicketsError(
            conferenceKey: this.checkInListItem, url: url, response: response));
      }
    }).catchError((e) {
      this.appState.bus.add(new TicketsError(
          conferenceKey: this.checkInListItem, url: url, error: e));
    });
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
  final List<FoundTickets> lastFoundTickets = new List();
  StreamSubscription subscription;

  TicketsAgent({ConfotorAppState appState}) : appState = appState;

  stop()  {
    subscription.cancel();
  }

  start() {
    subscription = this.appState.bus.stream.listen((msg) {
      if (msg is CheckInListsMsg) {
        msg.lists.forEach((i) {
          if (i.ticketsStatus == CheckInListItemTicketsStatus.Initial) {
            TicketsPages.fetch(appState: appState, item: i);
          }
        });
        checkInLists.clear();
        msg.lists.where((i) => i.ticketsStatus == CheckInListItemTicketsStatus.Fetched).forEach((item) {
          checkInLists.add(item);
        });
      }
      if (msg is TicketScanBarcodeMsg) {
        TicketScanBarcodeMsg tsmsg = msg;
        final found = findTickets(tsmsg.barcode);
        this.appState.bus.add(found);
        print('TicketScanBarcodeMsg:$found');
      }

      if (msg is CheckedTicket) {
        this.lastFoundTickets.where((fts) => fts.hasFound).where((fts) {
          return fts.tickets.indexWhere((ft) {
            if (ft.ticket.slug == msg.foundTicket.ticket.slug) {
              ft.checkedIns.add(msg);
              return true;
            }
            return false;
          }) >= 0;
        }).forEach((fts) =>
          this.appState.bus.add(FoundTickets(tickets: fts.tickets))
        );
      }

      if (msg is FoundTickets) {
        final idx = this.lastFoundTickets.indexWhere((t) => t.slug == msg.slug);
        if (idx >= 0) {
          this.lastFoundTickets.removeAt(idx);
        }
        this.lastFoundTickets.insert(0, msg);
        for(var i = 20; i < lastFoundTickets.length; i++) {
          lastFoundTickets.removeAt(20);
        }
        this.appState.bus.add(LastFoundTickets(last: lastFoundTickets), persist: true);
      }
    });
  }
}
