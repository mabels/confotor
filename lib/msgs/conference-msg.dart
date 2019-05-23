
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'confotor-msg.dart';

class RequestUpdateConference extends ConfotorMsg {
  final CheckInListItem checkInListItem;
  final List<TicketAndCheckIns> ticketAndCheckIns;
  RequestUpdateConference({@required CheckInListItem checkInListItem, @required List<TicketAndCheckIns> ticketAndCheckIns}):
    checkInListItem = checkInListItem,
    ticketAndCheckIns = ticketAndCheckIns;
}

class UpdatedConference extends ConfotorMsg {
  final CheckInListItem checkInListItem;
  UpdatedConference({@required CheckInListItem checkInListItem}): checkInListItem = checkInListItem;
}

class RequestRemoveConference extends ConfotorMsg {
  final ConferenceKey conference;
  RequestRemoveConference({@required ConferenceKey conference}): conference = conference;
}

class RemovedConference extends ConfotorMsg {
  final CheckInListItem checkInListItem;
  RemovedConference({@required CheckInListItem checkInListItem}): checkInListItem = checkInListItem;
}

