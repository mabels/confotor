import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/stores/ticket-and-checkins-store.dart';
import 'package:flutter/foundation.dart';

enum TicketStoreStatus { Initial, Fetched }

class TicketStore {
  TicketStoreStatus ticketsStatus = TicketStoreStatus.Initial;
  final Map<int, TicketAndCheckInsStore> _ticketAndCheckIns = new Map();
  final ConfotorAppState appState;

  TicketStore({@required ConfotorAppState appState}) : appState = appState;

  update(List<TicketAndCheckIns> list) {
    // final transaction = appState.uuid.v4();
    list.forEach((tac) => _ticketAndCheckIns
        .putIfAbsent(
            tac.ticket.id, () => TicketAndCheckInsStore(id: tac.ticket.id))
        .update(tac));
    return this;
  }

  updateCheckInActions(List<CheckInAction> ciams) {
    ciams.forEach((ciam) {
      try {
        _ticketAndCheckIns
            .putIfAbsent(ciam.ticketId,
                () => TicketAndCheckInsStore(id: ciam.ticketId))
            .checkInActions
            .update([ciam]);
      } catch (e) {
        // print('updateTickets:${tickets.length}:${ticket.id}:$e');
        throw e;
      }

      if (_ticketAndCheckIns.containsKey(ciam.ticketId)) {
        _ticketAndCheckIns[ciam.ticketId].checkInActions.update([ciam]);
        return;
      }
      throw Exception("updateCheckInItem ticketId:${ciam.ticketId} not found");
    });
  }

  updateCheckInItems(List<CheckInItem> ciims) {
    ciims.forEach((ciim) {
      // print('updateCheckInItems:${ciims.length}:${ciim.toJson()}');
      try {
        _ticketAndCheckIns
            .putIfAbsent(ciim.ticketId,
                () => TicketAndCheckInsStore(id: ciim.ticketId))
            .checkInItems
            .update([ciim]);
      } catch (e) {
        print('updateTickets:${ciims.length}:${ciim.ticketId}:$e');
        throw e;
      }
    });
  }

  updateTickets(List<Ticket> tickets) {
    tickets.forEach((ticket) {
      // print('updateTickets:${tickets.length}:${ticket}');
      try {
        _ticketAndCheckIns
            .putIfAbsent(ticket.id, () => TicketAndCheckInsStore(id: ticket.id))
            .ticket
            .update(ticket);
      } catch (e) {
        // print('updateTickets:${tickets.length}:${ticket.id}:$e');
        throw e;
      }
    });
  }

  TicketAndCheckInsStore firstWhere(
          bool test(TicketAndCheckInsStore element)) =>
      _ticketAndCheckIns.values.firstWhere(test, orElse: () => null);

  add(TicketAndCheckIns tac) {
    _ticketAndCheckIns
        .putIfAbsent(
            tac.ticket.id, () => TicketAndCheckInsStore(id: tac.ticket.id))
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
