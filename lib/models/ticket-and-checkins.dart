
import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:meta/meta.dart';

enum TicketAndCheckInsState {
  Used,
  Issueable,
  Issued,
  Error
}

TicketAndCheckInsState ticketAndCheckInsStateFromString(String s) {
  switch (s) {
    case 'Used': return TicketAndCheckInsState.Used;
    case 'Issueable': return TicketAndCheckInsState.Issueable;
    case 'Issued': return TicketAndCheckInsState.Issued;
    case 'Error': 
    default:
      return TicketAndCheckInsState.Error;
  }
}

class TicketAndCheckIns {
  final List<CheckInItem> checkInItems;
  final List<CheckInAction> checkInActions;
  final Ticket ticket;
  final TicketAndCheckInsState state;

  TicketAndCheckIns({
    @required List<CheckInItem> checkInItems,
    @required List<CheckInAction> checkInActions,
    @required Ticket ticket,
    @required TicketAndCheckInsState state
   }): checkInItems = checkInItems, 
       checkInActions = checkInActions, 
       ticket = ticket, 
       state = state;


  String get shortState {
    return state.toString().split(".").last;
  }

  static TicketAndCheckIns fromJson(dynamic json) {
    final my = TicketAndCheckIns(
       checkInActions: [], 
       checkInItems: [], 
       ticket: Ticket(id: json['ticket']['id']),
       state: ticketAndCheckInsStateFromString(json['state'])
    );
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
        "ticket": ticket
      };
}
