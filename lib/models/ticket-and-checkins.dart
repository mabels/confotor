
import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket.dart';

enum TicketAndCheckInsState {
  Used,
  Issueable,
  Issued,
  Error
}

class TicketAndCheckIns {
  final List<CheckInItem> checkInItems;
  final List<CheckInAction> checkInActions;
  final Ticket ticket;

  TicketAndCheckIns({
    List<CheckInItem> checkInItems,
    List<CheckInAction> checkInActions,
    Ticket ticket
   }): checkInItems = checkInItems, checkInActions = checkInActions, ticket = ticket;

  TicketAndCheckInsState get state {
    return TicketAndCheckInsState.Error;
  }

  String get shortState {
    return state.toString().split(".").last;
  }

  static fromJson(dynamic json) {
    final my = TicketAndCheckIns(checkInActions: [], checkInItems: [], ticket: Ticket());
    return my._updateFromJson(json);
  }

  TicketAndCheckIns _updateFromJson(dynamic json) {
    ticket.updateFromJson(json['ticket']);
    var loop = [];
    if (json['checkInActions'] != null) {
      loop = json['checkInActions'];
    }
    loop.forEach((i) => checkInActions.add(CheckInAction.fromJson(i)));
    loop = [];
    if (json['checkInItems'] != null) {
      loop = json['checkInItems'];
    }
    loop.forEach((i) => checkInItems.add(CheckInItem.fromJson(i)));
    return this;
  }

  Map<String, dynamic> toJson() => {
        "checkInItems": checkInItems,
        "checkInActions": checkInActions,
        "ticket": ticket.toJson()
      };
}
