import 'dart:convert';

import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:test_api/test_api.dart';

import 'check-in-item_test.dart';
import 'ticket_test.dart';

TicketAndCheckIns testTicketAndCheckins({
  int ticketId = 4711,
  List<CheckInItem> checkInItems
}) {
  if (checkInItems == null) {
    checkInItems = [testCheckInItem(ticketId: ticketId)];
  }
  return TicketAndCheckIns(checkInItems: checkInItems, ticket: testTicket(
    ticketId: ticketId
  ));
}

void main() {
  test('enum str -> enum', () {
    expect(
        ticketAndCheckInsStateFromString('xxx'), TicketAndCheckInsState.Error);
    expect(ticketAndCheckInsStateFromString('Error'),
        TicketAndCheckInsState.Error);
    expect(
        ticketAndCheckInsStateFromString('Used'), TicketAndCheckInsState.Used);
    expect(ticketAndCheckInsStateFromString('Issueable'),
        TicketAndCheckInsState.Issueable);
  });

  test('enum str -> enum', () {
    expect(
        ticketAndCheckInsStateToString(TicketAndCheckInsState.Error), "Error");
    expect(ticketAndCheckInsStateToString(TicketAndCheckInsState.Used), "Used");
    expect(ticketAndCheckInsStateToString(TicketAndCheckInsState.Issueable),
        "Issueable");
  });

  test("Serialize", () {
    final tacis = testTicketAndCheckins();
    final str = json.encode(tacis);
    final refTacis = TicketAndCheckIns.fromJson(json.decode(str));
    expect(tacis, refTacis);
  });
  
  test('Tacs ticket null exception', () {
    expect(() => TicketAndCheckIns(ticket: null, checkInItems: null), throwsException);
  });

  test('Tacs ticket.id null exception', () {
    expect(() => TicketAndCheckIns(ticket: testTicket(ticketId: null), checkInItems: null), throwsException);
  });

  test('Tacs skip checkInItems with wrong id', () {
    expect(() => TicketAndCheckIns(ticket: testTicket(ticketId: 4711), checkInItems: [
      testCheckInItem(ticketId: 4977)
    ]), throwsException);
  });

  test('Tacs TicketId from ticket', () {
    final tacs = TicketAndCheckIns(ticket: testTicket(ticketId: 4711), checkInItems: null);
    expect(tacs.ticketId, 4711);
  });

  test('Tacs TicketId from checkInItems', () {
    final tacs = TicketAndCheckIns(ticket: null, checkInItems: [
      testCheckInItem(ticketId: 4711)
    ]);
    expect(tacs.ticketId, 4711);
  });

  test('Tacs TicketId from empty checkInItems', () {
    expect(() => TicketAndCheckIns(ticket: null, checkInItems: []), throwsException);
  });

}
