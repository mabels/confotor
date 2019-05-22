
import 'package:confotor/models/check-in-actions.dart';
import 'package:confotor/models/check-in-items.dart';
import 'package:confotor/models/ticket.dart';
import 'package:meta/meta.dart';

import 'check-in-item.dart';
import 'check-in-list-item.dart';

enum TicketAndCheckInsState {
  Used,
  Issueable,
  Issued,
  Error
}

class TicketAndCheckIns {
  final CheckInItems checkInItems = CheckInItems();
  final CheckInActions checkInActions = CheckInActions();
  final Ticket ticket;

  TicketAndCheckIns({@required Ticket ticket}) :
    ticket = ticket;

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

  static TicketAndCheckIns fromJson(dynamic json) {
    TicketAndCheckIns(ticket: Ticket.fromJson(json['ticket'])).updateFromJson(json);
  }
  updateFromJson(dynamic json) {
    ticket.updateFromJson(json['ticket']);
    checkInActions.updateFromJson(json['checkInActions']);
    checkInItems.updateFromJson(json['checkInItems']);
    return this;
  }


  update(TicketAndCheckIns tac) {
    if (!(ticket.id == tac.id)) {
      throw Exception("Ticket update on wrong instance");
    }
    ticket.update(tac.ticket);
    checkInActions.update(tac.checkInActions);
    checkInItems.update(tac.checkInItems);
    // checkInActions.addAll(tac.checkInActions);
  }

  Map<String, dynamic> toJson() => {
        "checkInItems": checkInItems.toJson(),
        "checkInActions": checkInActions.toJson(),
        "ticket": ticket.toJson(),
      };
}
