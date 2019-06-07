import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'check-in-list-item.dart';

part 'conference.g.dart';

// This is the class used by rest of your codebase
class Conference extends ConferenceBase with _$Conference {
  Conference(
      {@required CheckInList checkInList,
      @required Iterable<TicketAndCheckIns> ticketAndCheckInsList,
      dynamic error})
      : super(
            checkInList: checkInList,
            ticketAndCheckInsList: ticketAndCheckInsList,
            error: error);

  static Conference fromJson(dynamic json) {
    final List<TicketAndCheckIns> ticketAndCheckInsList = [];
    if (json['ticketAndCheckInsList'] != null) {
      List<dynamic> my = json['ticketAndCheckInsList'];
      my.forEach(
          (j) => ticketAndCheckInsList.add(TicketAndCheckIns.fromJson(j)));
    }
    return Conference(
        checkInList: CheckInList.fromJson(json['checkInListItem']),
        ticketAndCheckInsList: ticketAndCheckInsList,
        error: json['error']);
  }
}

abstract class ConferenceBase with Store {
  final Observable<dynamic> _error;
  final CheckInList checkInList;
  final ObservableList<TicketAndCheckIns> ticketAndCheckInsList;

  ConferenceBase(
      {@required CheckInList checkInList,
      @required Iterable<TicketAndCheckIns> ticketAndCheckInsList,
      dynamic error})
      : _error = Observable(error),
        checkInList = checkInList,
        ticketAndCheckInsList = ObservableList.of(
            ticketAndCheckInsList == null ? [] : ticketAndCheckInsList);

  @computed
  get checkInItemLength {
    final i = ticketAndCheckInsList.map((t) => t.checkInItems.length);
    if (i.isEmpty) {
      return 0;
    }
    return i.reduce((a, b) => a + b);
  }

  @computed
  get url => checkInList.url;

  @computed
  get error => _error.value;

  @action
  set error(dynamic error) => _error.value = error;

  toJson() => {
        "checkInListItem": checkInList,
        "ticketStore": ticketAndCheckInsList,
        "error": _error.value
      };
}
