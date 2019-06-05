import 'dart:convert';

import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:test_api/test_api.dart';

import 'check-in-list-item_test.dart';
import 'ticket-and-checkins_test.dart';


void main() {
  test("Conferences isEmpty", () {
    final confs = Conferences(
      conferences: [ ]);
    expect(confs.conferences.isEmpty, true); 
  });

    test("Conferences !isEmpty", () {
    final confs = Conferences(
      conferences: [
        Conference(
          checkInList: testCheckInList(), 
          ticketAndCheckInsList: [
            testTicketAndCheckins()
          ]
        )]);
    expect(confs.conferences.isEmpty, false); 
  });

    test('Serialize', () {
          final confs = Conferences(
      conferences: [
        Conference(checkInList: testCheckInList(), ticketAndCheckInsList: [])
      ]);
    final str = json.encode(confs);
    final refCia = Conferences.fromJson(json.decode(str));
    expect(confs.conferences.first.url, refCia.conferences.first.url);
    });
}
