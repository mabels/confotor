
import 'dart:collection';

import 'package:confotor/confotor-app.dart';
import 'package:confotor/ticket.dart';
import 'package:meta/meta.dart';

import 'check-in-agent.dart';
import 'check-in-list.dart';




class AddCheckInItem {
  final CheckInItem item;
  AddCheckInItem({CheckInItem item}): item = item;
}

class CheckInAction {
  final String id;
  CheckInAction({ConfotorAppState appState}): id = appState.uuid.v4();
}

class AddCheckInAction {
  final CheckInAction item;
  AddCheckInAction({CheckInAction item}): item = item;

}

class TicketAndCheckIns {
  final Ticket ticket;
  final CheckInListItem checkInListItem;
  final Map<String/*uuid*/, CheckInItem> checkInItems = Map();
  final LinkedHashSet<CheckInAction> checkInActions = new LinkedHashSet(equals: (a, b) {
    return a.id == b.id;
  });

  TicketAndCheckIns({@required Ticket ticket, @required CheckInListItem checkInListItem}) :
    ticket = ticket, checkInListItem = checkInListItem;

  update(TicketAndCheckIns tac) {
    if (!(ticket.id == tac.id && checkInListItem.url == tac.checkInListItem.url)) {
      throw Exception("Ticket update on wrong instance");
    }
    ticket.update(tac.ticket);
    checkInItems.addAll(tac.checkInItems);
    checkInActions.addAll(tac.checkInActions);
  }

  get id {
    return ticket.id;
  }

  get state {
    return TicketAndCheckInsState.Error;
  }

  get shortState {
    return state.toString().split('.').last;
  }

  static TicketAndCheckIns fromJson(dynamic json) {
    if (json["slug"] != null) {
      // old
      // print('TicketAndCheckIns:OLD');
      return TicketAndCheckIns(ticket: Ticket.create(json));
    } else {
      // print('TicketAndCheckIns:NEW');
      final ret = TicketAndCheckIns(ticket: Ticket.create(json['ticket']));
      List<dynamic> checkInItems = json['checkInItems'];
      if (checkInItems == null) {
        checkInItems = [];
      }
      checkInItems.forEach((jsonItem) {
        final item = CheckInItem.fromJson(jsonItem);
        ret.checkInItems.putIfAbsent(item.uuid, () => item).update(item);
      });
      return ret;
    }
  }

  Map<String, dynamic> toJson() => {
        "ticket": ticket,
        "checkInItems": checkInItems.values.toList(),
      };
}
