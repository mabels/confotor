import 'dart:convert';

import 'package:confotor/models/conference-ticket.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/models/lane.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:test_api/test_api.dart';

import 'check-in-list-item_test.dart';
import 'ticket-and-checkins_test.dart';

ConferenceTicket testConferenceTicket({
  int ticketId,
  String url
  }) {
  return ConferenceTicket(
      checkInList: testCheckInList(url: url),
      ticketAndCheckIns: testTicketAndCheckins(ticketId: ticketId),
      actions: []);
}

FoundTickets testFoundTickets(
    {String range, int ticketId = 471, List<ConferenceTicket> conferenceTickets}) {
  if (conferenceTickets == null) {
    conferenceTickets = [
      testConferenceTicket(ticketId: ticketId),
      testConferenceTicket(ticketId: ticketId + 1000)
    ];
  }
  return FoundTickets(
      scan: 'jo', lane: Lane(range), conferenceTickets: conferenceTickets);
}

void main() {

  test("ConferenceTicket", () {
    final ct = testConferenceTicket();
    expect(ct is ConfotorMsg, true);
    final str = json.encode(ct);
    final refCt = ConferenceTicket.fromJson(json.decode(str));
    expect(ct, refCt);
  });

  test("FoundTickets", () {
    final fts = testFoundTickets();
    expect(fts is ConfotorMsg, true);
    final str = json.encode(fts);
    final refFts = FoundTickets.fromJson(json.decode(str));

    expect(fts == refFts, true);
  });

  test('foundTickets slugs', () {
    final fts = testFoundTickets();
    expect(fts.slugs, ['slug471', 'slug1471']);
  });

  test('foundTickets isInTicketLane', () {
    final fts = testFoundTickets(range: 'a-n');
    expect(fts.isInTicketLane, true);
  });

  test('foundTickets !isInTicketLane', () {
    final fts = testFoundTickets(range: 'n-z');
    expect(fts.isInTicketLane, false);
  });

  test('foundTickets unamiguous', () {
    final fts = testFoundTickets(conferenceTickets: [
      testConferenceTicket(url: 'url1', ticketId: 4),
      testConferenceTicket(url: 'url2', ticketId: 5),
    ]);
    expect(fts.unambiguous, true);
  });

  test('foundTickets !unamiguous', () {
    final fts = testFoundTickets(conferenceTickets: [
      testConferenceTicket(url: 'url1', ticketId: 4),
      testConferenceTicket(url: 'url2', ticketId: 5),
      testConferenceTicket(url: 'url1', ticketId: 6)
    ]);
    expect(fts.unambiguous, false);
  });

  test('foundTickets !containsSlug', () {
    final fts = testFoundTickets();
    expect(fts.containsSlug(testFoundTickets(ticketId: 77)), false);
  });

  test('foundTickets containsSlug', () {
    final fts = testFoundTickets();
    expect(fts.containsSlug(fts), true);
  });

  test('foundTickets !hasFound', () {
    final fts = testFoundTickets(conferenceTickets: []);
    expect(fts.hasFound, false);
  });

  test('foundTickets hasFound', () {
    final fts = testFoundTickets();
    expect(fts.hasFound, true);
  });

  test('foundTickets !name', () {
    final fts = testFoundTickets(conferenceTickets: []);
    expect(fts.name, "John Doe");
  });

  test('foundTickets name', () {
    final fts = testFoundTickets();
    expect(fts.name, "firstName lastName");
  });

}
