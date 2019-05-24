import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:confotor/stores/ticket-and-checkins-store.dart';
import 'package:flutter/foundation.dart';

enum TicketStoreStatus { Initial, Fetched }

class TicketStore {
  TicketStoreStatus ticketsStatus = TicketStoreStatus.Initial;
  final Map<int, TicketAndCheckInsStore> _ticketAndCheckIns = new Map();
  final ConfotorAppState appState;
  final CheckInList _checkInListItem;

  TicketStore(
      {@required ConfotorAppState appState,
      @required CheckInList checkInListItem})
      : _checkInListItem = checkInListItem,
        appState = appState;

  update(List<TicketAndCheckIns> list) {
    // final transaction = appState.uuid.v4();
    list.forEach((tac) => appState.bus.add(ConferenceTicket(
        checkInListItem: _checkInListItem,
        ticketAndCheckIns: _ticketAndCheckIns
            .putIfAbsent(
                tac.ticket.id, () => TicketAndCheckInsStore(ticket: tac.ticket))
            .update(tac)
            .asTicketAndCheckIns())));
    return this;
  }

  updateCheckInActions(List<CheckInAction> ciams) {
    ciams.forEach((ciam) {
      if (_ticketAndCheckIns.containsKey(ciam.ticket_id)) {
        _ticketAndCheckIns[ciam.ticket_id].checkInActions.update([ciam]);
        return;
      }
      throw Exception(
          "updateCheckInItem ticketId:${ciam.ticket_id}:${_checkInListItem.url} not found");
    });
  }

  updateCheckInItems(List<CheckInItem> ciims) {
    ciims.forEach((ciim) {
      if (_ticketAndCheckIns.containsKey(ciim.ticket_id)) {
        _ticketAndCheckIns[ciim.ticket_id].checkInItems.update([ciim]);
        return;
      }
      throw Exception(
          "updateCheckInItem ticketId:${ciim.ticket_id}:${_checkInListItem.url} not found");
    });
  }

  updateTickets(List<Ticket> tickets) {
    tickets.forEach((ticket) {
      if (_ticketAndCheckIns.containsKey(ticket.id)) {
        _ticketAndCheckIns[ticket.id].ticket.update(ticket);
        return;
      }
      throw Exception(
          "updateCheckInItem ticketId:${ticket.id}:${_checkInListItem.url} not found");
    });
  }

  TicketAndCheckInsStore firstWhere(
          bool test(TicketAndCheckInsStore element)) =>
      _ticketAndCheckIns.values.firstWhere(test, orElse: () => null);

  add(TicketAndCheckIns tac) {
    _ticketAndCheckIns
        .putIfAbsent(
            tac.ticket.id, () => TicketAndCheckInsStore(ticket: tac.ticket))
        .update(tac);
  }

  get ticketsCount {
    return _ticketAndCheckIns.length;
  }

  get checkInCount {
    return _ticketAndCheckIns.values
        .map((i) => i.checkInItems.length)
        .reduce((v, r) => v + r);
  }

  Iterable<TicketAndCheckInsStore> get values {
    return _ticketAndCheckIns.values;
  }

  Map<String, dynamic> toJson() => {
        "ticketsStatus": this.ticketsStatus,
        "ticketAndCheckIns": this._ticketAndCheckIns.values.toList()
      };

  // static TicketStoreStatus ticketsStatusFromJson(String ts) {
  //   switch (ts) {
  //     case 'Fetched':
  //       return TicketStoreStatus.Fetched;
  //     case 'Initial':
  //     default:
  //       return TicketStoreStatus.Initial;
  //   }
  // }

  // static TicketStore fromJson(dynamic json) {
  //   return TicketStore().updateFromJson(json);
  // }

  // updateFromJson(dynamic json) {
  //   List<dynamic> ticketsList = json;
  //   if (ticketsList == null) {
  //     ticketsList = [];
  //   }
  //   ticketsList.forEach((jsonTicket) {
  //     _ticketAndCheckIns.putIfAbsent(jsonTicket['id'],
  //     () => TicketAndCheckIns.fromJson(jsonTicket)).updateFromJson(jsonTicket);
  //   });
  //   ticketsStatus = ticketsStatusFromJson(json['ticketsStatus']);
  //   return this;
  // }

}
