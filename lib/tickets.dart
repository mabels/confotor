import 'dart:async';

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

class TicketsAgent {
  final ConfotorAppState appState;
  final Map<String, Tickets> tickets = new Map();

  TicketsAgent({ConfotorAppState appState}) : appState = appState;

  start() {
    this.appState.bus.stream.listen((msg) {
      if (msg is CheckInListsMsg) {
        msg.lists.forEach((i) {
          if (i.ticketsStatus == CheckInListItemTicketsStatus.Initial &&
              !tickets.containsKey(i.url)) {
            Tickets.fetch(appState: appState, item: i);
          }
        });
      }
    });
  }
}
