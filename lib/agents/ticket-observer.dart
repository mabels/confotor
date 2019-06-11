import 'dart:async';
import 'dart:convert';

import 'package:confotor/agents/paged-observer.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/fix-http-client.dart';
import 'package:confotor/models/ticket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';

part 'ticket-observer.g.dart';

class TicketPagedAction extends PagedAction {
  final Conference _conference;
  final Duration _pollInterval; 
  final PagedObserver _pagedObserver;

  TicketPagedAction({
    @required Conference conference,
    @required PagedObserver pagedObserver,
    Duration pollInterval
   }) : _conference = conference, _pagedObserver = pagedObserver, _pollInterval = pollInterval {
     _pagedObserver.start(this);
   }

  @override
  String fetchUrl(String transaction, int page) {
    return _conference.checkInList.ticketsUrl(page + 1);
  }

  @override
  Timer nextPoll(void Function() onPoll) {
    if (_pollInterval != null) {
      return Timer(_pollInterval, () => _pagedObserver.start(this));
    }
    return null;
  }

  @override
  PagedStep process(String transaction, int page, dynamic json) {
    final items = (json as Iterable<dynamic>).map((f) => Ticket.fromJson(f));
    _conference.updateTickets(transaction, items);
    return items.isNotEmpty ? PagedStep.Next : PagedStep.Done;
  }
}

// This is the class used by rest of your codebase
class TicketObserver extends TicketObserverBase with _$TicketObserver {
  TicketObserver(
      {@required Conference conference,
       @required ConfotorAppState appState,
       BaseClient client})
      : super(conference: conference, 
              client: client, appState: appState);
}

abstract class TicketObserverBase with Store {
  final PagedObserver pagedObserver;
  final Conference _conference;

  TicketObserverBase(
      {@required ConfotorAppState appState,
      @required Conference conference,
      BaseClient client})
      : _conference = conference,
        pagedObserver = PagedObserver(appState: appState, client: client);
  // checkInList = checkInList;

  get url => _conference.url;

  TicketObserver start({@required Duration pollInterval}) {
    TicketPagedAction(
      conference: _conference,
      pollInterval: pollInterval,
      pagedObserver: pagedObserver
    );
    return this;
  }

  stop() {
    pagedObserver.stop();
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
