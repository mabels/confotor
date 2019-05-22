import 'package:confotor/ticket-and-checkins.dart';

import 'check-in-list.dart';



class TicketStore {
  CheckInListItemTicketsStatus ticketsStatus =
      CheckInListItemTicketsStatus.Initial;
  final Map<int, TicketAndCheckIns> ticketAndCheckIns = new Map();

  add(TicketAndCheckIns tac) {
    ticketAndCheckIns.putIfAbsent(tac.id, () => tac).update(tac);
  }

  get ticketsCount {
    return ticketAndCheckIns.length;
  }
  get checkInCount {
    return ticketAndCheckIns.values.map((i) => i.checkInItems.length).reduce((v, r) => v + r);
  }

  get values {
    return ticketAndCheckIns.values;
  }

  Map<String, dynamic> toJson() => {
    "ticketsStatus": this.ticketsStatus,
    "ticketAndCheckIns": this.ticketAndCheckIns.values.toList()
  };

  static CheckInListItemTicketsStatus ticketsStatusFromJson(String ts) {
    switch (ts) {
      case 'Fetched':
        return CheckInListItemTicketsStatus.Fetched;
      case 'Initial':
      default:
        return CheckInListItemTicketsStatus.Initial;
    }
  }

  static TicketStore fromJson(dynamic json) {
    final ts = TicketStore();

    List<dynamic> ticketsList = json;
    if (ticketsList == null) {
      ticketsList = [];
    }
    ticketsList.forEach((jsonTicket) {
      ts.add(TicketAndCheckIns.fromJson(jsonTicket));
    });
    ts.ticketsStatus = ticketsStatusFromJson(json['ticketsStatus']);
    return ts;
  }
}
