import 'dart:async';
import 'dart:collection';

// import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
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

class TicketsError extends ConfotorMsg {
  final String url;
  final CheckInListItem checkInListItem;
  final http.Response response;
  final dynamic error;
  TicketsError(
      {String url,
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

class FoundTicket {
  final CheckInListItem checkInListItem;
  final Ticket ticket;
  FoundTicket({CheckInListItem checkInListItem, Ticket ticket}):
    checkInListItem = checkInListItem, ticket = ticket;
}

class FoundTickets extends ConfotorMsg {
  final List<FoundTicket> tickets;
  FoundTickets({List<FoundTicket> tickets}): tickets = tickets;
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

  TicketsAgent({ConfotorAppState appState}) : appState = appState;

  FoundTickets findTickets(String slug) {
    final List<FoundTicket> ret = [];
    checkInLists.firstWhere((item) {
      print('findTickets:${item.url}:${item.ticketsCount}:$slug');
      final found = item.tickets.firstWhere((ticket) {
        print('findTickets:${item.url}:${item.ticketsCount}:$slug:${ticket.slug}');
        return ticket.slug == slug;
      }, orElse: () => null);
      print('findTickets:NEXT:${item.url}:${item.ticketsCount}:$slug:$found');
      if (found != null) {
        print("findTickets:Found:${found.slug}:${slug}");
        ret.add(FoundTicket(checkInListItem: item, ticket: found));
      }
      return found != null;
    });
    if (ret.isNotEmpty) {
      final ref = ret.first;
      checkInLists.forEach((item) {
        if (item != ref.checkInListItem) {
          item.tickets.forEach((ticket) {
            if (ticket.registration_reference == ref.ticket.registration_reference) {
              ret.add(FoundTicket(checkInListItem: item, ticket: ticket));
              return;
            }
            if (ticket.email == ref.ticket.email) {
              if (ticket.company_name == ref.ticket.company_name) {
                if (ticket.first_name == ref.ticket.first_name) {
                  if (ticket.last_name == ref.ticket.last_name) {
                    ret.add(FoundTicket(checkInListItem: item, ticket: ticket));
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

  start() {
    this.appState.bus.stream.listen((msg) {
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

      if (msg is FoundTickets) {
        this.lastFoundTickets.insert(0, msg);
        for(var i = 5; i < lastFoundTickets.length; i++) {
          lastFoundTickets.removeAt(5);
        }
        this.appState.bus.add(LastFoundTickets(last: lastFoundTickets), persist: true);
      }
    });
  }
}
