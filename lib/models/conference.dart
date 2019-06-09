import 'package:confotor/agents/tickets-agent.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'check-in-list-item.dart';

part 'conference.g.dart';

// This is the class used by rest of your codebase
class Conference extends ConferenceBase with _$Conference {
  Conference(
      {@required CheckInList checkInList,
      @required Iterable<TicketAndCheckIns> ticketAndCheckInsList,
      dynamic error})
      : super(
            checkInList: checkInList,
            ticketAndCheckInsList: ticketAndCheckInsList,
            error: error);

  static Conference fromJson(dynamic json) {
    final List<TicketAndCheckIns> ticketAndCheckInsList = [];
    if (json['ticketAndCheckInsList'] != null) {
      List<dynamic> my = json['ticketAndCheckInsList'];
      my.forEach(
          (j) => ticketAndCheckInsList.add(TicketAndCheckIns.fromJson(j)));
    }
    return Conference(
        checkInList: CheckInList.fromJson(json['checkInListItem']),
        ticketAndCheckInsList: ticketAndCheckInsList,
        error: json['error']);
  }
}

abstract class ConferenceBase with Store {
  final Observable<dynamic> _error;
  final CheckInList checkInList;
  final ObservableList<TicketAndCheckIns> _ticketAndCheckInsList;
  final Map<int, Transaction<int>> _tacisIdx = Map();

  ConferenceBase(
      {@required CheckInList checkInList,
      @required Iterable<TicketAndCheckIns> ticketAndCheckInsList,
      dynamic error})
      : _error = Observable(error),
        checkInList = checkInList,
        _ticketAndCheckInsList = ObservableList.of(
            ticketAndCheckInsList == null ? [] : ticketAndCheckInsList);

  @computed
  get checkInItemLength {
    final i = _ticketAndCheckInsList.map((t) => t.checkInItems.length);
    if (i.isEmpty) {
      return 0;
    }
    return i.reduce((a, b) => a + b);
  }

  @computed
  Iterable<TicketAndCheckIns> get ticketAndCheckInsList => _ticketAndCheckInsList;

  @computed
  get ticketAndCheckInsLength => _ticketAndCheckInsList.length;

  @action
  updateTickets(String transaction, Iterable<Ticket> tickets) {
    if (tickets.isEmpty) {
      _tacisIdx.values.toList().forEach((idx) {
        if (idx.transaction != transaction) {
          final tac = _ticketAndCheckInsList.removeAt(idx.value);
          _tacisIdx.remove(tac.ticketId);
        }
      });
      return;
    }
    tickets.forEach((ticket) {
      final idx = _tacisIdx.putIfAbsent(ticket.id, () {
        _ticketAndCheckInsList.add(TicketAndCheckIns(
          ticket: ticket,
          checkInItems: []
        ));
        return Transaction(transaction: transaction, value: _ticketAndCheckInsList.length -1);
      });
      _ticketAndCheckInsList[idx.value].ticket.update(ticket);
    });
  }

  @computed
  get url => checkInList.url;

  @computed
  get error => _error.value;

  @action
  set error(dynamic error) => _error.value = error;

  toJson() => {
        "checkInListItem": checkInList,
        "ticketStore": _ticketAndCheckInsList,
        "error": _error.value
      };

}
