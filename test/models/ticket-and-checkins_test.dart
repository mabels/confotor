import 'dart:convert';

import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:test_api/test_api.dart';

import 'check-in-item_test.dart';
import 'ticket_test.dart';

TicketAndCheckIns testTicketAndCheckins({
  int ticketId,
  List<CheckInItem> checkInItems
}) {
  if (checkInItems == null) {
    checkInItems = [testCheckInItem()];
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
    expect(tacis.checkInItems, refTacis.checkInItems);
    expect(tacis.ticket, tacis.ticket);
  });

  test("lastCheckIn", () {
    final first = DateTime.now();
    final next = DateTime.now();
    final last = DateTime.now();
    final tacis = testTicketAndCheckins(checkInItems: [
      testCheckInItem(createdAt: last),
      testCheckInItem(createdAt: next, deletedAt: last),
      testCheckInItem(createdAt: first)
    ]);
    expect(tacis.lastCheckedIn, tacis.checkInItems.first);
  });
}
