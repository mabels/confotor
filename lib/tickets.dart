import 'dart:async';
import 'dart:collection';

// import 'package:flutter/widgets.dart';
import 'package:confotor/check-in-agent.dart';
import 'package:confotor/ticket-and-checkins.dart';
import 'package:confotor/ticket-store.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import './check-in-list.dart';
import './confotor-app.dart';
import './confotor-msg.dart';
// import 'package:sprintf/sprintf.dart';
import 'dart:convert' as convert;
import './ticket.dart';

enum TicketsStatus { Initial, Page, Ready, Error }

class TicketsMsg {
  TicketsStatus status;
  int page;
  int totalTickets;
  TicketsMsg({status: TicketsStatus, page: int, totalTickets: int}) {
    this.status = status;
    this.page = page;
    this.totalTickets = totalTickets;
  }
}

// class TicketsCompleteMsg extends ConfotorMsg {
//   TicketsCompleteMsg(
//       {CheckInListItem checkInListItem, Map<int, Ticket> tickets, String url})
//       : checkInListItem = checkInListItem,
//         tickets = tickets,
//         url = url;
// }

class TicketsPageMsg extends ConfotorMsg {
  final String transaction;
  final CheckInListItem checkInListItem;
  final Map<int, Ticket> tickets;
  final int page;
  final bool completed;
  TicketsPageMsg({
    final String transaction,
    final CheckInListItem checkInListItem,
    final Map<int, Ticket> tickets,
    final int page,
    final bool completed
    }) :
      transaction = transaction,
      checkInListItem = checkInListItem,
      tickets = tickets,
      page = page,
      completed = completed;
}

class TicketsError extends ConfotorMsg implements ConfotorErrorMsg {
  final String url;
  final CheckInListItem checkInListItem;
  final http.Response response;
  final dynamic error;
  TicketsError({String url,
      CheckInListItem checkInListItem,
      http.Response response,
      dynamic error})
      : url = url,
        checkInListItem = checkInListItem,
        response = response,
        error = error;
}

class TicketsPages {
  final ConfotorAppState appState;
  final String transaction;
  final CheckInListItem checkInListItem;
  // final Map<int, Ticket> tickets = new Map();

  static TicketsPages fetch({ConfotorAppState appState, CheckInListItem item}) {
    var tickets = new TicketsPages(appState: appState, item: item);
    tickets.getPages(0);
    return tickets;
  }

  TicketsPages({ConfotorAppState appState, CheckInListItem item})
    : transaction = appState.uuid.v4(),
      appState = appState,
      checkInListItem = item;

  getPages(int page) {
    final url = this.checkInListItem.ticketsUrl(page);
    print("getPage:$url");
    http.get(url).then((response) {
      if (200 <= response.statusCode && response.statusCode < 300) {
        Iterable jsonResponse = convert.jsonDecode(response.body);
        Map<int, Ticket> tickets = new Map();
        jsonResponse.forEach((f) {
          Ticket ticket = Ticket.create(f);
          tickets[ticket.id] = ticket;
        });
        // this.tickets.addAll(tickets);
        this.appState.bus.add(new TicketsPageMsg(
            transaction: transaction,
            checkInListItem: this.checkInListItem,
            tickets: tickets,
            page: page,
            completed: page >= this.checkInListItem.total_pages));
        if (page < this.checkInListItem.total_pages) {
          getPages(page + 1);
        }
      } else {
        this.appState.bus.add(new TicketsError(
            checkInListItem: this.checkInListItem, url: url, response: response));
      }
    }).catchError((e) {
      this.appState.bus.add(new TicketsError(
          checkInListItem: this.checkInListItem, url: url, error: e));
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

class FoundTickets extends ConfotorMsg {
  final List<TicketAndCheckIns> tickets;
  FoundTickets({@required List<TicketAndCheckIns> tickets}): tickets = tickets;

  get hasFound {
    return tickets.isNotEmpty;
  }
  get slug {
    return hasFound ? tickets.first.ticket.slug : "Not Found";
  }
  get name {
    return hasFound ? "${tickets.first.ticket.first_name} ${tickets.first.ticket.last_name}" : "John Doe";
  }
}

const List<FoundTickets> emptyFoundTickets = [];
class LastFoundTickets extends ConfotorMsg {
  final List<FoundTickets> last;
  LastFoundTickets({List<FoundTickets> last = emptyFoundTickets}): last = List.from(last);
}

class TicketsAgent {
  final ConfotorAppState appState;
  final List<CheckInListItem> checkInLists = [];
  // final Map<String, Tickets> tickets = new Map();
  final List<FoundTickets> lastFoundTickets = new List();
  StreamSubscription subscription;

  TicketsAgent({ConfotorAppState appState}) : appState = appState;

  FoundTickets findTickets(String slug) {
    final List<TicketStore> ret = [];
    checkInLists.indexWhere((item) {
      // print('findTickets:${item.url}:${item.ticketsCount}:$slug');
      final found = item.ticketStore.values.firstWhere((tac) {
        // print('findTickets:${item.url}:${item.ticketsCount}:$slug:${ticket.slug}');
        return tac.ticket.slug == slug;
      }, orElse: () => null);
      // print('findTickets:NEXT:${item.url}:${item.ticketsCount}:$slug:$found');
      if (found != null) {
        // print("findTickets:Found:${found.slug}:${slug}");
        ret.add(found);
      }
      return found != null;
    });
    if (ret.isNotEmpty) {
      final ref = ret.first;
      checkInLists.forEach((item) {
        if (item != ref.checkInListItem) {
          item.ticketAndCheckIns.values.forEach((tac) {
            final ticket = tac.ticket;
            if (ticket.registration_reference == ref.ticket.registration_reference) {
              ret.add(tac);
              return;
            }
            if (ticket.email == ref.ticket.email) {
              if (ticket.company_name == ref.ticket.company_name) {
                if (ticket.first_name == ref.ticket.first_name) {
                  if (ticket.last_name == ref.ticket.last_name) {
                    ret.add(tac);
                  }
                }
              }
              return;
            }
          });
        }
      });
    }
    return FoundTickets(tickets: ret);
  }


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
