// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/models/lane.dart';
import 'package:confotor/models/ticket-action.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:flutter_test/flutter_test.dart';

import 'check-in-list-item_test.dart';
import 'found-tickets_test.dart';
import 'ticket_test.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(ConfotorApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  test('Serialize', () {
    LastFoundTickets lastFoundTickets = LastFoundTickets(last: [
      FoundTickets(
          lane: Lane('G-U'),
          conferenceTickets: [
            ConferenceTicket(
                actions: [
                  AmbiguousAction(barcode: 'x'),
                  BarcodeScannedTicketAction(barcode: 'x', lane: Lane('A-c')),
                  CheckInTransactionTicketAction(
                      step: CheckInOutTransactionTicketActionStep.Completed),
                  CheckInTransactionTicketAction(
                      step: CheckInOutTransactionTicketActionStep.Started),
                  CheckInTransactionTicketAction(
                      step: CheckInOutTransactionTicketActionStep.Error),
                  CheckOutTransactionTicketAction(
                      step: CheckInOutTransactionTicketActionStep.Error,
                      uuid: 'x'),
                ],
                checkInList: testCheckInList(),
                ticketAndCheckIns:
                    TicketAndCheckIns(checkInItems: [], ticket: testTicket(ticketId: 1)))
          ],
          scan: "xx")
    ]);
    final String str = json.encode(lastFoundTickets.toJson());
    // print(str);
    final dynamic my = json.decode(str);
    final ref = LastFoundTickets.fromJson(my);
    expect(ref.length, 1);
    expect(ref.first.lane.toString(), 'G-U');
    expect(ref.first.scan, 'xx');
    final ct = ref.first.conferenceTickets.first;
    expect(ct.checkInList.url, 'test://url');
    expect(ct.ticketAndCheckIns.checkInItems.length, 0);
    expect(ct.ticketAndCheckIns.ticket.id, 1);
    expect(ct.actions.length, 6);
    // print(ct.actions);
    AmbiguousAction aaction = ct.actions[0];
    BarcodeScannedTicketAction baction = ct.actions[1];
    CheckInTransactionTicketAction ccomplete = ct.actions[2];
    CheckInTransactionTicketAction cstarted = ct.actions[3];
    CheckInTransactionTicketAction cerror = ct.actions[4];
    CheckOutTransactionTicketAction cout = ct.actions[5];
    expect(aaction.type, "AmbiguousAction");
    expect(aaction.barcode, 'x');
    expect(baction.type, "BarcodeScannedTicketAction");
    expect(baction.barcode, 'x');
    expect(baction.lane.toString(), 'A-C');
    expect(ccomplete.type, "CheckInTransactionTicketAction");
    expect(ccomplete.step, CheckInOutTransactionTicketActionStep.Completed);
    expect(cstarted.type, "CheckInTransactionTicketAction");
    expect(cstarted.step, CheckInOutTransactionTicketActionStep.Started);
    expect(cerror.type, "CheckInTransactionTicketAction");
    expect(cerror.step, CheckInOutTransactionTicketActionStep.Error);
    expect(cout.type, "CheckOutTransactionTicketAction");
    expect(cout.step, CheckInOutTransactionTicketActionStep.Error);
    expect(cout.uuid, 'x');
  });

  test("LastFoundTickets copy last", () {
    final lfts = LastFoundTickets(last: []);
    expect(lfts is ConfotorMsg, true);
    expect(lfts.maxLen, 20);
  });

  test("LastFoundTickets maxlen", () {
    final lfts = LastFoundTickets(last: [], maxLen: 30);
    expect(lfts is ConfotorMsg, true);
    expect(lfts.maxLen, 30);
    expect(lfts.length, 0);
  });

  test("LastFoundTickets clone and copy last instance", () {
    final lfts = LastFoundTickets(last: [], maxLen: 30).clone();
    expect(lfts is ConfotorMsg, true);
    expect(lfts.maxLen, 30);
    expect(lfts.length, 0);
  });

  test("LastFoundTickets clone and copy last instance", () {
    final my = LastFoundTickets(last: [
      testFoundTickets(ticketId: 2),
      testFoundTickets(ticketId: 1)
    ], maxLen: 30);
    final lfts = my.clone();
    expect(lfts is ConfotorMsg, true);
    expect(lfts.maxLen, 30);
    final List<FoundTickets> fts = List.from(lfts.values);
    expect(fts.first.conferenceTickets.first.ticketAndCheckIns.ticket.id, 2);
    expect(fts.last.conferenceTickets.first.ticketAndCheckIns.ticket.id, 1);
  });

  test('LastFoundTickets Serialize', () {
    final confs = LastFoundTickets(
        last: [testFoundTickets(), testFoundTickets(), testFoundTickets()]);
    final str = json.encode(confs);
    final refCia = LastFoundTickets.fromJson(json.decode(str));
    expect(confs.maxLen, refCia.maxLen);
    expect(confs.length, 1);
  });

  test('LastFoundTickets Init Cut', () {
    final confs = LastFoundTickets(maxLen: 5, last: [
      testFoundTickets(ticketId: 1),
      testFoundTickets(ticketId: 2),
      testFoundTickets(ticketId: 3),
      testFoundTickets(ticketId: 4),
      testFoundTickets(ticketId: 5),
      testFoundTickets(ticketId: 6)
    ]);
    expect(confs.maxLen, 5);
    expect(confs.length, 5);
    expect(confs.first.conferenceTickets.first.ticketAndCheckIns.ticket.id, 1);
    expect(confs.last.conferenceTickets.first.ticketAndCheckIns.ticket.id, 5);
  });

  test('LastFoundTickets Append Cut', () {
    final lfts = LastFoundTickets(maxLen: 5, last: [
      testFoundTickets(ticketId: 1),
      testFoundTickets(ticketId: 2),
      testFoundTickets(ticketId: 3),
      testFoundTickets(ticketId: 4),
      testFoundTickets(ticketId: 5),
      testFoundTickets(ticketId: 6)
    ]);
    for (int i = 0; i < 100; ++i) {
      lfts.append(testFoundTickets(ticketId: i+10));
    }
    expect(lfts.maxLen, 5);
    expect(lfts.length, 5);
    expect(lfts.first.conferenceTickets.first.ticketAndCheckIns.ticket.id, 109);
  });

  test('LastFoundTickets Post Cut', () {
    final confs = LastFoundTickets(maxLen: 5, last: [
      testFoundTickets(ticketId: 1),
      testFoundTickets(ticketId: 2),
      testFoundTickets(ticketId: 3),
      testFoundTickets(ticketId: 4),
      testFoundTickets(ticketId: 5),
      testFoundTickets(ticketId: 6)
    ]);
    confs.maxLen = 2;
    expect(confs.maxLen, 2);
    expect(confs.length, 2);
    expect(confs.first.conferenceTickets.first.ticketAndCheckIns.ticket.id, 1);
    expect(confs.last.conferenceTickets.first.ticketAndCheckIns.ticket.id, 2);
  });

  test('LastFoundTickets Lift Up', () {
    final confs = LastFoundTickets(maxLen: 5, last: [
      testFoundTickets(ticketId: 1),
      testFoundTickets(ticketId: 2),
      testFoundTickets(ticketId: 3),
      testFoundTickets(ticketId: 4),
      testFoundTickets(ticketId: 5),
      testFoundTickets(ticketId: 6)
    ]);
    confs.append(testFoundTickets(ticketId: 4));
    expect(confs.first.conferenceTickets.first.ticketAndCheckIns.ticket.id, 4);
  });
}
