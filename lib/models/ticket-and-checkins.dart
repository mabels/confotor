
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:meta/meta.dart';

enum TicketAndCheckInsState {
  Used,
  Issueable,
  // Issued,
  Error
}

TicketAndCheckInsState ticketAndCheckInsStateFromString(String s) {
  switch (s) {
    case 'Used': return TicketAndCheckInsState.Used;
    case 'Issueable': return TicketAndCheckInsState.Issueable;
    // case 'Issued': return TicketAndCheckInsState.Issued;
    case 'Error': 
    default:
      return TicketAndCheckInsState.Error;
  }
}

String ticketAndCheckInsStateToString(TicketAndCheckInsState s) {
  switch (s) {
    case TicketAndCheckInsState.Used: return "Used";
    case TicketAndCheckInsState.Issueable: return "Issueable";
    // case TicketAndCheckInsState.Issued: return "Issued";
    case TicketAndCheckInsState.Error: return "Error";
  }
}

class TicketAndCheckIns {
  final List<CheckInItem> checkInItems;
  // final List<CheckInAction> checkInActions;
  final Ticket ticket;
  // final TicketAndCheckInsState state;

  TicketAndCheckIns({
    @required List<CheckInItem> checkInItems,
    // @required List<CheckInAction> checkInActions,
    @required Ticket ticket,
    // @required TicketAndCheckInsState state
   }): checkInItems = checkInItems, 
      //  checkInActions = checkInActions, 
       ticket = ticket; 
      //  state = state;

  updateCheckInItems(List<CheckInItem> ciis) {
    final lookup = Map.fromEntries(ciis.map((cii) => MapEntry(cii.uuid, cii)));
    checkInItems.forEach((cii) {
      if (lookup.containsKey(cii.uuid)) {
        cii.update(lookup[cii.uuid]);
        lookup.remove(cii.uuid);
      }
    });
    checkInItems.addAll(lookup.values);
  }

  // String get shortState {
  //   return state.toString().split(".").last;
  // }

  CheckInItem get lastCheckedIn {
    final toSort = checkInItems.where((cii) => cii.deleted_at == null).toList();
    toSort.sort((a, b) => a.created_at.compareTo(b.created_at));
    return toSort.last;
  }

  static TicketAndCheckIns fromJson(dynamic json) {
    final List<CheckInItem> ciis = [];
    if (json['checkInItems'] is List) {
      final List<dynamic> ljson = json['checkInItems'];
      ciis.addAll(ljson.map((o) => CheckInItem.fromJson(o)));
    }
    final my = TicketAndCheckIns(
      //  checkInActions: [], 
       checkInItems: ciis,
       ticket: Ticket(id: json['ticket']['id']),
      //  state: ticketAndCheckInsStateFromString(json['state'])
    );
    return my._updateFromJson(json);
  }

  TicketAndCheckIns _updateFromJson(dynamic json) {
    ticket.updateFromJson(json['ticket']);
    var loop = [];
    // if (json['checkInActions'] != null) {
      // loop = json['checkInActions'];
    // }
    // loop.forEach((i) => checkInActions.add(CheckInAction.fromJson(i)));
    // loop = [];
    if (json['checkInItems'] != null) {
      loop = json['checkInItems'];
    }
    loop.forEach((i) => checkInItems.add(CheckInItem.fromJson(i)));
    return this;
  }

  Map<String, dynamic> toJson() => {
        "checkInItems": checkInItems,
        // "checkInActions": checkInActions,
        "ticket": ticket,
        // "state": ticketAndCheckInsStateToString(state)
      };
}
