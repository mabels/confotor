import 'package:confotor/agents/tickets-agent.dart';
import 'package:confotor/models/check-in-item.dart';
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
  final Map<int /* ticketId */, Transaction<int>> _tacisIdx = Map();
  final ObservableList<TicketAndCheckIns> _ticketAndCheckInsList =
      ObservableList();
  final Observable<dynamic> _error;
  final CheckInList checkInList;

  ConferenceBase(
      {@required CheckInList checkInList,
      @required Iterable<TicketAndCheckIns> ticketAndCheckInsList,
      dynamic error})
      : _error = Observable(error),
        checkInList = checkInList {
    final String transaction = 'constructor';
    if (!(ticketAndCheckInsList is Iterable)) {
      ticketAndCheckInsList = [];
    }
    updateTickets(transaction, ticketAndCheckInsList.map((i) => i.ticket));
    updateCheckInItems(
        transaction, ticketAndCheckInsList.expand((i) => i.checkInItems.iterable));
  }

  @action
  void updateCheckInItems(
    String transaction, Iterable<CheckInItem> checkInItems) {
    checkInItems = checkInItems.where((i) => i != null);
    checkInItems.forEach((cis) {
      final idx = _manageTicketIndex(transaction, cis.ticketId, checkInItem: cis);
      final checkInItem = _ticketAndCheckInsList[idx.value].checkInItems;
      checkInItem.updateCheckInItem(cis);
    });
  }

  void _cleanupTransaction(String transaction) {
    _tacisIdx.values.toList().forEach((idx) {
      if (idx.transaction != transaction) {
        final tac = _ticketAndCheckInsList.removeAt(idx.value);
        _tacisIdx.remove(tac.ticketId);
      }
    });
  }

  Transaction<int> _manageTicketIndex(String transaction, int ticketId, {
    Ticket ticket,
    CheckInItem checkInItem
  }) {
      final idx = _tacisIdx.putIfAbsent(ticketId, () {
        _ticketAndCheckInsList
            .add(TicketAndCheckIns(ticket: ticket, checkInItems: [checkInItem]));
        return Transaction(
            transaction: transaction, value: ticketAndCheckInsList.length - 1);
      });
      idx.transaction = transaction;
      return idx;
  }

  @action
  void updateTickets(String transaction, Iterable<Ticket> tickets) {
    if (tickets == null) {
      tickets = [];
    } else {
      tickets = tickets.where((i) => i != null);
    }
    tickets.forEach((ticket) {
      final idx = _manageTicketIndex(transaction, ticket.id, ticket: ticket);
      _ticketAndCheckInsList[idx.value].ticket.update(ticket);
    });
    _cleanupTransaction(transaction);
    return;
  }

  @computed
  get checkInItemLength {
    final i = _ticketAndCheckInsList.map((t) => t.checkInItems.length);
    if (i.isEmpty) {
      return 0;
    }
    return i.reduce((a, b) => a + b);
  }

  @computed
  Iterable<TicketAndCheckIns> get ticketAndCheckInsList =>
      _ticketAndCheckInsList;

  @computed
  get ticketAndCheckInsLength => _ticketAndCheckInsList.length;

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
