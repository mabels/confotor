import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:meta/meta.dart';
import 'check-in-actions-store.dart';
import 'check-in-items-store.dart';

enum TicketAndCheckInsState { Used, Issueable, Issued, Error }

class TicketAndCheckInsStore {
  final CheckInItemsStore checkInItems = CheckInItemsStore();
  final CheckInActionsStore checkInActions = CheckInActionsStore();
  final Ticket ticket;

  TicketAndCheckInsStore({@required Ticket ticket}) : ticket = ticket;

  get id {
    return ticket.id;
  }

  get slug {
    return ticket.slug;
  }

  get state {
    return TicketAndCheckInsState.Error;
  }

  get shortState {
    return state.toString().split('.').last;
  }

  TicketAndCheckInsStore update(TicketAndCheckIns tac) {
    if (!(ticket.id == tac.ticket.id)) {
      throw Exception("Ticket update on wrong instance");
    }
    ticket.update(tac.ticket);
    checkInActions.update(tac.checkInActions);
    checkInItems.update(tac.checkInItems);
    // checkInActions.addAll(tac.checkInActions);
    return this;
  }

  TicketAndCheckIns asTicketAndCheckIns() {
    return TicketAndCheckIns(
      ticket: ticket, checkInActions: checkInActions.toList(), checkInItems: checkInItems.toList()
    );
  }

  Map<String, dynamic> toJson() => {
        "checkInItems": checkInItems.toJson(),
        "checkInActions": checkInActions.toJson(),
        "ticket": ticket.toJson(),
      };
}
