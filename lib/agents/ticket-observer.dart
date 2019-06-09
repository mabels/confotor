import 'dart:async';
import 'dart:convert';

import 'package:confotor/models/conference.dart';
import 'package:confotor/models/fix-http-client.dart';
import 'package:confotor/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';

part 'ticket-observer.g.dart';

enum TicketsStatus { Idle, Fetching, Error }

// This is the class used by rest of your codebase
class TicketObserver extends TicketObserverBase with _$TicketObserver {
  TicketObserver(
      {@required ConfotorAppState appState,
      @required Conference conference,
      BaseClient client})
      : super(appState: appState, conference: conference, client: client);
}

abstract class TicketObserverBase with Store {
  @observable
  TicketsStatus status = TicketsStatus.Idle;
  @observable
  dynamic error;
  @observable
  Response response;

  final ConfotorAppState _appState;
  final Conference _conference;
  final BaseClient _client;
  // final Observable<CheckInList> checkInList;
  Timer _timer;
  Duration _duration;

  // static TicketObserver fetch(
  //     {ConfotorAppState appState, ConferenceKey conference}) {
  //   final tickets = TicketObserver(appState: appState, conference: conference);
  //   tickets.getPages(0);
  //   return tickets;
  // }

  TicketObserverBase(
      {@required ConfotorAppState appState,
      @required Conference conference,
      BaseClient client})
      : _appState = appState,
        _conference = conference,
        _client = client;
  // checkInList = checkInList;

  get url => _conference.url;

  @action
  _thenResponse(String transaction, int page, Response response) {
    this.response = response;
    // print(
    //     'TicketAgent:getPages:$url:$page:$transaction:${response.statusCode}');
    if (200 <= response.statusCode && response.statusCode < 300) {
      try {
        Iterable jsonResponse = json.decode(response.body);
        // this.tickets.addAll(tickets);
        final items = jsonResponse.map((f) => Ticket.fromJson(f));
        _conference.updateTickets(transaction, items);
        if (items.isNotEmpty) {
          getPages(page + 1, transaction);
        } else {
          status = TicketsStatus.Idle;
          _timer = Timer(_duration, () => getPages(1, _appState.uuid.v4()));
        }
      } catch (e) {
        status = TicketsStatus.Error;
        error = e;
      }
    } else {
      // print("TicketsError:ResponseCode:getPage:$url:${response.statusCode}");
      status = TicketsStatus.Error;
      error = Exception("ResponseCode:getPage:$url:${response.statusCode}");
    }
  }

  @action
  getPages(int page, String transaction) {
    status = TicketsStatus.Fetching;
    final confKey = this._conference.checkInList;
    final url = confKey.ticketsUrl(page);
    // print('TicketAgent:getPages:$url:$page:$transaction');
    fixHttpClient(_client)
        .get(url)
        .then((response) => _thenResponse(transaction, page, response))
        .catchError((e) {
      Action(() {
        status = TicketsStatus.Error;
        response = null;
        error = e;
      })();
    });
  }

  TicketObserver start({int hours = 4}) {
    ReactionDisposer dispose;
    dispose = reaction((_) => status, (state) {
      if (state == TicketsStatus.Idle || state == TicketsStatus.Error) {
        if (dispose != null) {
          dispose();
        }
        _duration = Duration(hours: hours);
        stop();
        getPages(1, _appState.uuid.v4()); // paged api triggered by page 1
        return this;
      }
    }, fireImmediately: true);
    return this;
  }

  stop() {
    if (_timer != null) {
      _timer.cancel();
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
