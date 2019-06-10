import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'check-in-items.dart';

part 'ticket-and-checkins.g.dart';

enum TicketAndCheckInsState { Used, Issueable, Error }

TicketAndCheckInsState ticketAndCheckInsStateFromString(String s) {
  switch (s) {
    case 'Used':
      return TicketAndCheckInsState.Used;
    case 'Issueable':
      return TicketAndCheckInsState.Issueable;
    // case 'Issued': return TicketAndCheckInsState.Issued;
    case 'Error':
    default:
      return TicketAndCheckInsState.Error;
  }
}

String ticketAndCheckInsStateToString(TicketAndCheckInsState s) {
  switch (s) {
    case TicketAndCheckInsState.Used:
      return "Used";
    case TicketAndCheckInsState.Issueable:
      return "Issueable";
    // case TicketAndCheckInsState.Issued: return "Issued";
    case TicketAndCheckInsState.Error:
    default:
      return "Error";
  }
}

class TicketAndCheckIns extends TicketAndCheckInsBase with _$TicketAndCheckIns {
  TicketAndCheckIns({
    @required Iterable<CheckInItem> checkInItems,
    @required Ticket ticket,
  }) : super(checkInItems: checkInItems, ticket: ticket);

  static TicketAndCheckIns fromJson(dynamic json) {
    final my = TicketAndCheckIns(
      checkInItems: CheckInItems.fromJson(json['checkInItems']).iterable,
      ticket: json['ticket'] == null ? null : Ticket.fromJson(json['ticket']),
    );
    return my;
  }
}

abstract class TicketAndCheckInsBase with Store {
  final int _ticketId;
  final CheckInItems checkInItems;
  @observable
  Ticket _ticket;

  static int _getTicketId(Iterable<CheckInItem> checkInItems, Ticket ticket) {
    if (ticket != null && ticket.id != null) {
      return ticket.id;
    }
    if (checkInItems is Iterable) {
      final ciis = checkInItems.where((i) => i != null && i.ticketId != null);
      if (ciis.isNotEmpty) {
        return ciis.first.ticketId;
      }
    }
    throw Exception("Ticket And CheckIns without Id");
  }

  static Ticket _checkTicket(int ticketId, Ticket ticket) {
    if (ticket != null && ticketId == ticket.id) {
      return Ticket.clone(ticket);
    }
    return null;
  }

  TicketAndCheckInsBase({
    Iterable<CheckInItem> checkInItems,
    Ticket ticket,
  })  : _ticketId = _getTicketId(checkInItems, ticket),
        _ticket = _checkTicket(_getTicketId(checkInItems, ticket), ticket),
        checkInItems = CheckInItems(
            ticketId: _getTicketId(checkInItems, ticket),
            checkInItems: checkInItems);

  @action
  Ticket get ticket => _ticket;

  int get ticketId => _ticketId;

  @override
  bool operator ==(o) {
    return (o is TicketAndCheckIns || o is TicketAndCheckInsBase) &&
        o.checkInItems == checkInItems &&
        o.ticket == ticket;
  }

  @action
  updateTicket(Ticket oth) {
    if (_ticket == null) {
      _ticket = Ticket.clone(oth);
    } else {
      _ticket.update(oth);
    }
  }

  Map<String, dynamic> toJson() => {
        "checkInItems": checkInItems,
        "ticket": _ticket,
      };
}
