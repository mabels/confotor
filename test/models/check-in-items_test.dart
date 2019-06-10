
import 'dart:convert';

import 'package:confotor/models/check-in-items.dart';
import 'package:test_api/test_api.dart';

import 'check-in-item_test.dart';
import 'ticket-and-checkins_test.dart';

void main() {
  test('checkInitems null', () {
    expect(() => CheckInItems(ticketId: null, checkInItems: null), throwsException);
  });
  test('checkInitems ticketId', () {
    final ciis = CheckInItems(ticketId: 4711, checkInItems: null);
    expect(ciis.ticketId, 4711);
  });

  test('checkInitems ticketId missmatch constructor', () {
    expect(() => CheckInItems(ticketId: 4711, checkInItems: [testCheckInItem(ticketId: 4911)]), 
      throwsException);
  });
  test('checkInitems ticketId missmatch update', () {
    final ciis = CheckInItems(ticketId: 4711, checkInItems: null);
    expect(ciis.ticketId, 4711);
    expect(() => ciis.updateCheckInItem(testCheckInItem(ticketId: 4911)), throwsException);
  });

  test('checkInitems serialize', () {
    final ciis = CheckInItems(ticketId: 4711, checkInItems: [
      testCheckInItem(ticketId: 4711, uuid: 'uuid2'),
      testCheckInItem(ticketId: 4711, uuid: 'uuid1')
    ]);
    final str = json.encode(ciis);
    final dciis = CheckInItems.fromJson(json.decode(str));

    expect(dciis.first.uuid, 'uuid1');
    expect(dciis.last.uuid, 'uuid2');
    expect(dciis, ciis);
  });

    test("lastCheckIn", () {
    final first = DateTime.now();
    final next = DateTime.now();
    final last = DateTime.now();
    final tacis = testTicketAndCheckins(ticketId: 44, checkInItems: [
      testCheckInItem(ticketId: 44, createdAt: last),
      testCheckInItem(ticketId: 44, createdAt: next, deletedAt: last),
      testCheckInItem(ticketId: 44, createdAt: first)
    ]);
    expect(tacis.checkInItems.lastCheckedIn, tacis.checkInItems.first);
  });

  test('checkInitems restore ordered', () {
    final ci = [
      testCheckInItem(ticketId: 4711, uuid: 'uuid1'),
      testCheckInItem(ticketId: 4711, uuid: 'uuid2'),
      testCheckInItem(ticketId: 4711, uuid: 'uuid1', deletedAt: DateTime.now()),
    ];
    final ciis = CheckInItems(ticketId: 4711, checkInItems: ci);
    expect(ciis.length, 2); 
    expect(ciis.checkInItems.first, ci[2]); 
    expect(ciis.checkInItems.last, ci[1]); 
  });

  test('checkInitems update ordered', () {
    final ci = [
      testCheckInItem(ticketId: 4711, uuid: 'uuid1'),
      testCheckInItem(ticketId: 4711, uuid: 'uuid2'),
      testCheckInItem(ticketId: 4711, uuid: 'uuid1', deletedAt: DateTime.now()),
    ];
    final ciis = CheckInItems(ticketId: 4711, checkInItems: null);
    ci.forEach((cii) => ciis.updateCheckInItem(cii));
    expect(ciis.length, 2); 
    expect(ciis.checkInItems.first, ci[2]); 
    expect(ciis.checkInItems.last, ci[1]); 
  });

}