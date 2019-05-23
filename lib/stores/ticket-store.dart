import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/stores/ticket-and-checkins-store.dart';
import 'package:flutter/foundation.dart';

enum TicketStoreStatus { Initial, Fetched }

class TicketStore {
  TicketStoreStatus ticketsStatus = TicketStoreStatus.Initial;
  final Map<int, TicketAndCheckInsStore> _ticketAndCheckIns = new Map();
  final ConfotorAppState appState;

  TicketStore({@required ConfotorAppState appState}): appState = appState;

  update(List<TicketAndCheckIns> list) {
    final transaction = appState.uuid.v4();
    list.forEach((tac) =>
      appState.bus.add(ConferenceTicket(
        ticketAndCheckIns: _ticketAndCheckIns
          .putIfAbsent(tac.ticket.id, () => TicketAndCheckInsStore(ticket: tac.ticket))
          .update(tac),
        checkInListItem: checkListItem;
      ));
    );
    return this;
  }

  firstWhere(bool test(TicketAndCheckIns element)) => _ticketAndCheckIns.values.firstWhere(test, orElse: () => null);
  add(TicketAndCheckIns tac) {
    _ticketAndCheckIns.putIfAbsent(tac.id, () => tac).update(tac);
  }

  get ticketsCount {
    return _ticketAndCheckIns.length;
  }
  get checkInCount {
    return _ticketAndCheckIns.values.map((i) => i.checkInItems.length).reduce((v, r) => v + r);
  }

  get values {
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
