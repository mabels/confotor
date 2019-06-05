import 'dart:convert';

import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:meta/meta.dart';
import 'package:test_api/test_api.dart';

import 'check-in-list-item_test.dart';

class My extends ConferenceKey {
  My(String url) : super(url);
}

void main() {
  test("ConferenceKey listId", () {
    final my = My(
        "https://ti.to/jsconfeu/jonf-eu-x-2019/checkin_lists/xxxxxxxxx.json");
    expect(my.listId, "xxxxxxxxx");
  });

  test("ConferenceKey ticketsUrl", () {
    final my = My(
        "https://ti.to/jsconfeu/jonf-eu-x-2019/checkin_lists/xxxxxxxxx.json");
    expect(my.ticketsUrl(1),
        'https://checkin.tito.io/checkin_lists/xxxxxxxxx/tickets?page=1');
  });

  test("ConferenceKey ticketsUrl", () {
    final my = My(
        "https://ti.to/jsconfeu/jonf-eu-x-2019/checkin_lists/xxxxxxxxx.json");
    expect(my.checkInUrl(),
        'https://checkin.tito.io/checkin_lists/xxxxxxxxx/checkins?since=0&page=0');
    expect(my.checkInUrl(since: 4711, page: 4),
        'https://checkin.tito.io/checkin_lists/xxxxxxxxx/checkins?since=4711&page=4');
  });

  test("ConferenceKey ticketsUrl", () {
    final my = My(
        "https://ti.to/jsconfeu/jonf-eu-x-2019/checkin_lists/xxxxxxxxx.json");
    expect(my.checkOutUrl('uuid'),
        "https://checkin.tito.io/checkin_lists/xxxxxxxxx/checkins/uuid");
  });

  test("Conference Serialize", () {
    final conf = Conference(
        checkInList: testCheckInList(),
        ticketAndCheckInsList: [TicketAndCheckIns(
          checkInItems: [],
          ticket: Ticket()
        )]);
    final str = json.encode(conf);
    var refConf = Conference.fromJson(json.decode(str));
    expect(conf.checkInList.url, refConf.checkInList.url);
  });
}

class Conference {
  final CheckInList checkInList;
  final List<TicketAndCheckIns> ticketAndCheckInsList;

  Conference(
      {@required CheckInList checkInList,
      @required List<TicketAndCheckIns> ticketAndCheckInsList})
      : checkInList = checkInList,
        ticketAndCheckInsList = ticketAndCheckInsList;

  get checkInItemLength {
    final i = ticketAndCheckInsList.map((t) => t.checkInItems.length);
    if (i.isEmpty) {
      return 0;
    }
    return i.reduce((a, b) => a + b);
  }

  static Conference fromJson(dynamic json) {
    final List<TicketAndCheckIns> ticketAndCheckInsList = [];
    if (json['ticketAndCheckInsList'] != null) {
      List<dynamic> my = json['ticketAndCheckInsList'];
      my.forEach(
          (j) => ticketAndCheckInsList.add(TicketAndCheckIns.fromJson(j)));
    }
    return Conference(
        checkInList: CheckInList.fromJson(json['checkInListItem']),
        ticketAndCheckInsList: ticketAndCheckInsList);
  }

  get url => checkInList.url;

  toJson() =>
      {"checkInListItem": checkInList, "ticketStore": ticketAndCheckInsList};
}
