// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:flutter_test/flutter_test.dart';

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
      FoundTickets(conferenceTickets: [
        ConferenceTicket(
            actions: [
              BarcodeScannedTicketAction(barcode: 'x'),
              CheckInTransactionTicketAction(
                  step: CheckInOutTransactionTicketActionStep.Completed),
              CheckInTransactionTicketAction(
                  step: CheckInOutTransactionTicketActionStep.Started),
              CheckInTransactionTicketAction(
                  step: CheckInOutTransactionTicketActionStep.Error),
              CheckOutTransactionTicketAction(
                  step: CheckInOutTransactionTicketActionStep.Error, uuid: 'x'),
            ],
            checkInList: CheckInList(url: 'x'),
            ticketAndCheckIns: TicketAndCheckIns(
                checkInItems: [],
                ticket: Ticket(id: 1)))
      ])
    ]);
    final String str = json.encode(lastFoundTickets.toJson());
    // print(str);
    final dynamic my = json.decode(str);
    final ref = LastFoundTickets.fromJson(my);
    expect(ref.last.length, 1);
    final ct = ref.last.first.conferenceTickets.first;
    expect(ct.checkInList.url, 'x');
    expect(ct.ticketAndCheckIns.checkInItems.length, 0);
    expect(ct.ticketAndCheckIns.ticket.id, 1);
    expect(ct.actions.length, 5);
    // print(ct.actions);
    BarcodeScannedTicketAction baction = ct.actions[0];
    CheckInTransactionTicketAction ccomplete = ct.actions[1];
    CheckInTransactionTicketAction cstarted = ct.actions[2];
    CheckInTransactionTicketAction cerror = ct.actions[3];
    CheckOutTransactionTicketAction cout = ct.actions[4];
    expect(baction.barcode, 'x');
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
}
