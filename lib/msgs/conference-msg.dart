
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'confotor-msg.dart';

class RequestUpdateConference extends ConfotorMsg {
  final ConferenceKey checkInListItem;
  final Conference conference;
  RequestUpdateConference({@required ConferenceKey checkInListItem, Conference conference}):
    checkInListItem = checkInListItem,
    conference = conference;
}

class UpdatedConference extends ConfotorMsg {
  final ConferenceKey checkInListItem;
  final Conference conference;
  UpdatedConference({@required ConferenceKey checkInListItem, Conference conference}): 
    checkInListItem = checkInListItem,
    conference = conference;
}

class RequestRemoveConference extends ConfotorMsg {
  final ConferenceKey conference;
  RequestRemoveConference({@required ConferenceKey conference}): conference = conference;
}

class RemovedConference extends ConfotorMsg {
  final ConferenceKey checkInListItem;
  RemovedConference({@required ConferenceKey checkInListItem}): checkInListItem = checkInListItem;
}

