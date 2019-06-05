
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:flutter/foundation.dart';
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
  final Ticket ticket;

  TicketAndCheckIns({
    @required List<CheckInItem> checkInItems,
    @required Ticket ticket,
   }): checkInItems = checkInItems,
       ticket = ticket;

  bool operator ==(o) {
    return o is TicketAndCheckIns &&
      listEquals(o.checkInItems, checkInItems) &&
      o.ticket == ticket;
  }

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
    final toSort = checkInItems.where((cii) => cii.deletedAt == null).toList();
    toSort.sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
       ticket: Ticket.fromJson(json['ticket']),
      //  state: ticketAndCheckInsStateFromString(json['state'])
    );
    return my;
  }

  // TicketAndCheckIns _updateFromJson(dynamic json) {
  //   var loop = [];
  //   if (json['checkInItems'] != null) {
  //     loop = json['checkInItems'];
  //   }
  //   loop.forEach((i) => checkInItems.add(CheckInItem.fromJson(i)));
  //   return this;
  // }

  Map<String, dynamic> toJson() => {
        "checkInItems": checkInItems,
        // "checkInActions": checkInActions,
        "ticket": ticket,
        // "state": ticketAndCheckInsStateToString(state)
      };
}
