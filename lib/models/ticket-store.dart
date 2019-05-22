import 'package:confotor/models/ticket-and-checkins.dart';

enum TicketStoreStatus { Initial, Fetched }

class TicketStore {
  TicketStoreStatus ticketsStatus = TicketStoreStatus.Initial;
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

  static TicketStoreStatus ticketsStatusFromJson(String ts) {
    switch (ts) {
      case 'Fetched':
        return TicketStoreStatus.Fetched;
      case 'Initial':
      default:
        return TicketStoreStatus.Initial;
    }
  }

  static TicketStore fromJson(dynamic json) {
    return TicketStore().updateFromJson(json);
  }

  updateFromJson(dynamic json) {
    List<dynamic> ticketsList = json;
    if (ticketsList == null) {
      ticketsList = [];
    }
    ticketsList.forEach((jsonTicket) {
      ticketAndCheckIns.putIfAbsent(jsonTicket['id'], 
      () => TicketAndCheckIns.fromJson(jsonTicket)).updateFromJson(jsonTicket);
    });
    ticketsStatus = ticketsStatusFromJson(json['ticketsStatus']);
    return this;
  }

}
