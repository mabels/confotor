import 'package:confotor/msgs/confotor-msg.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'ticket-and-checkins.dart';
import 'check-in-list-item.dart';
import 'ticket-action.dart';

class RequestCheckOutTicket extends ConfotorMsg {
  final ConferenceTicket conferenceTicket;
  RequestCheckOutTicket({@required ticket}) : conferenceTicket = ticket;
}

class RequestCheckInTicket extends ConfotorMsg {
  final ConferenceTicket conferenceTicket;
  RequestCheckInTicket({@required ticket}) : conferenceTicket = ticket;
}

class ConferenceTicket extends ConfotorMsg {
  final CheckInList checkInList;
  final TicketAndCheckIns ticketAndCheckIns;
  final List<TicketAction> actions;
  // TicketAndCheckInsState state = TicketAndCheckInsState.Error;

  ConferenceTicket(
      {@required CheckInList checkInList,
      @required TicketAndCheckIns ticketAndCheckIns,
      @required List<TicketAction> actions})
      : checkInList = checkInList,
        ticketAndCheckIns = ticketAndCheckIns,
        actions = actions;

  @override
  bool operator ==(o) {
    return o is ConferenceTicket &&
     o.checkInList == checkInList &&
     o.ticketAndCheckIns == ticketAndCheckIns &&
     listEquals(o.actions, actions);
  }

  static _actionsFromJson(dynamic actions) {
    final List<TicketAction> my = [];
    if (actions is List) {
      actions.forEach((ajson) => my.add(TicketAction.fromJson(ajson)));
    }
    return my;
  }

  static ConferenceTicket fromJson(dynamic json) {
    return ConferenceTicket(
        checkInList: CheckInList.fromJson(json['checkInList']),
        ticketAndCheckIns:
            TicketAndCheckIns.fromJson(json['ticketAndCheckIns']),
        actions: _actionsFromJson(json['actions']));
  }

  Map<String, dynamic> toJson() => {
    "checkInList": checkInList,
    "ticketAndCheckIns": ticketAndCheckIns,
    "actions": actions
  };


  bool get issuedFromMe {
    final action = actions.reversed.firstWhere((action) {
      return action is CheckInTransactionTicketAction ||
             action is CheckOutTransactionTicketAction;
    }, orElse: () => null);
    return action is CheckInTransactionTicketAction &&
           action.step == CheckInOutTransactionTicketActionStep.Completed;
  }

  bool get runningAction {
    return actions.firstWhere((action) {
      if (action is CheckInTransactionTicketAction ||
          action is CheckOutTransactionTicketAction) {
            final StepTransactionTicketAction my  = action;
            return !(my.step == CheckInOutTransactionTicketActionStep.Completed ||
                     my.step == CheckInOutTransactionTicketActionStep.Error);
          }
      return false;
    }, orElse: () => null) != null;
  }

  TicketAndCheckInsState get state {
    // ticketAndCheckIns.checkInItems.forEach((ci) => print('cii:${ticketAndCheckIns.ticket.reference}:${json.encode(ci)}'));
    final open = ticketAndCheckIns.checkInItems.firstWhere((i) => i.deletedAt == null, orElse: () => null);
    if (open != null) {
      return TicketAndCheckInsState.Used;
    }
    return TicketAndCheckInsState.Issueable;
  }

  String get shortState => state.toString().split(".").last;

}
