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

class TicketsCompleteMsg extends ConfotorMsg {
  final String url;
  final CheckInListItem checkInListItem;
  final Map<int, Ticket> tickets;
  TicketsCompleteMsg(
      {CheckInListItem checkInListItem, Map<int, Ticket> tickets, String url})
      : checkInListItem = checkInListItem,
        tickets = tickets,
        url = url;
}

class TicketsPageMsg extends TicketsCompleteMsg {
  TicketsPageMsg(
      {CheckInListItem checkInListItem, Map<int, Ticket> tickets, String url})
      : super(checkInListItem: checkInListItem, tickets: tickets, url: url);
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

class Tickets {
  String transaction;
  CheckInListItem checkInListItem;
  ConfotorAppState appState;
  Map<int, Ticket> tickets = new Map();

  // getPages(int page) {
  //   this.getPage(page).then((next) {
  //     this.appState.bus.add(TicketsMsg(
  //         status: TicketsStatus.Page,
  //         page: page,
  //         totalTickets: tickets.length));
  //     if (next == TicketsStatus.Page) {
  //       getPages(page + 1);
  //     } else {
  //       this.appState.bus.add(
  //           TicketsMsg(status: next, page: page, totalTickets: tickets.length));
  //     }
  //   });
  // }

  static Tickets fetch({ConfotorAppState appState, CheckInListItem item}) {
    var tickets = new Tickets(appState: appState, item: item);
    tickets.getPage(0);
    return tickets;
  }

  Tickets({ConfotorAppState appState, CheckInListItem item}) {
    this.transaction = appState.uuid.v4();
    this.appState = appState;
    this.checkInListItem = item;
  }

  // setStatus(FetchStatus status) {
  //   print(sprintf("TicketState:%s:%d", [status, this.tickets.length]));
  //   this.status = status;
  // }

  getPage(int page) {
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
        this.tickets.addAll(tickets);
        this.appState.bus.add(new TicketsPageMsg(
            url: url, checkInListItem: this.checkInListItem, tickets: tickets));
        if (page >= this.checkInListItem.total_pages) {
          this.appState.bus.add(new TicketsCompleteMsg(
              url: url,
              checkInListItem: this.checkInListItem,
              tickets: this.tickets));
        } else {
          getPage(page + 1);
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
  final Tickets tickets;
  final Ticket ticket;
  FoundTicket({Tickets tickets, Ticket ticket}):
    tickets = tickets, ticket = ticket;
}

const List<FoundTicket> emptyFoundTicket = [];
class FoundTickets extends ConfotorMsg {
  final List<FoundTicket> tickets;
  FoundTickets({List<FoundTicket> tickets = emptyFoundTicket}): tickets = tickets;
  get hasFound {
    return tickets.isNotEmpty;
  }
}

const List<FoundTickets> emptyFoundTickets = [];
class ActiveFoundTickets extends ConfotorMsg {
  final List<FoundTickets> active;
  ActiveFoundTickets({List<FoundTickets> active = emptyFoundTickets}): active = List.from(active);
}

class TicketsAgent {
  final ConfotorAppState appState;
  final Map<String, Tickets> tickets = new Map();
  final List<FoundTickets> active = new List();

  TicketsAgent({ConfotorAppState appState}) : appState = appState;

  FoundTickets findTickets(String slug) {
    final ret = FoundTickets();
    print("findTickets:${tickets.values.length}:${slug}");
    tickets.values.forEach((tickets) {
      final found = tickets.tickets.values.firstWhere((ticket) => ticket.slug == slug);
      if (found != null) {
        print("findTickets:Found:${found.slug}:${slug}");
        ret.tickets.add(FoundTicket(tickets: tickets, ticket: found));
      }
    });
    if (ret.hasFound) {
      final ref = ret.tickets.first;
      tickets.values.forEach((tickets) {
        if (tickets != ref.tickets) {
          tickets.tickets.values.forEach((ticket) {
            if (ticket.registration_reference == ref.ticket.registration_reference) {
              ret.tickets.add(FoundTicket(tickets: tickets, ticket: ticket));
              return;
            }
            if (ticket.email == ref.ticket.email) {
              if (ticket.company_name == ref.ticket.company_name) {
                if (ticket.first_name == ref.ticket.first_name) {
                  if (ticket.last_name == ref.ticket.last_name) {
                    ret.tickets.add(FoundTicket(tickets: tickets, ticket: ticket));
                  }
                }
              }
              return;
            }
          });
        }
      });
    }
    return ret;
  }

  start() {
    this.appState.bus.stream.listen((msg) {
      if (msg is CheckInListsMsg) {
        msg.lists.forEach((i) {
          if (i.ticketsStatus == CheckInListItemTicketsStatus.Initial &&
              !tickets.containsKey(i.url)) {
            Tickets.fetch(appState: appState, item: i);
          } else {
            tickets.clear();
            tickets[i.url] = new Tickets(appState: appState, item: i);
          }
        });
      }
      if (msg is TicketScanBarcodeMsg) {
        TicketScanBarcodeMsg tsmsg = msg;
        final found = findTickets(tsmsg.barcode);
        this.appState.bus.add(found);
        print('TicketScanBarcodeMsg:$found');
      }
      if (msg is FoundTickets) {
        this.active.insert(0, msg);
        for(var i = 5; i < active.length; i++) {
          this.active.removeAt(5);
        }
        this.appState.bus.add(ActiveFoundTickets(active: active), persist: true);
      }
    });
  }
}
