
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'confotor-msg.dart';

class RequestUpdateConference extends ConfotorMsg {
  final CheckInList checkInList;
  final Conference conference;
  RequestUpdateConference({@required CheckInList checkInList, Conference conference}):
    checkInList = checkInList,
    conference = conference;
}

class UpdatedConference extends ConfotorMsg {
  final CheckInList checkInList;
  final Conference conference;
  UpdatedConference({@required CheckInList checkInList, Conference conference}):
    checkInList = checkInList,
    conference = conference;
}

class RequestRemoveConference extends ConfotorMsg {
  final ConferenceKey conference;
  RequestRemoveConference({@required ConferenceKey conference}): conference = conference;
}

class RemovedConference extends ConfotorMsg {
  final ConferenceKey checkInList;
  RemovedConference({@required ConferenceKey checkInList}): checkInList = checkInList;
}

class RequestConferencesMsg extends ConfotorMsg {}

class RemoveConferences extends ConfotorMsg {
  final List<ConferenceKey> items;
  RemoveConferences({@required List<ConferenceKey> items}) : items = items;
}
const List<ConferenceKey> empty = [];
class RefreshConferences extends ConfotorMsg {
  final List<ConferenceKey> items;
  RefreshConferences({List<ConferenceKey> items: empty}) : items = items;
}