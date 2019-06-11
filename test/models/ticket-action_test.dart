import 'dart:convert';

import 'package:confotor/models/checked-in-response.dart';
import 'package:confotor/models/lane.dart';
import 'package:confotor/models/ticket-action.dart';
import 'package:confotor/models/ticket-actions.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test_api/test_api.dart';

import 'checked-in-response_test.dart';

testTicketActions() {
  return TicketActions([
    AmbiguousAction(barcode: 'barcode'),
    BarcodeScannedTicketAction(barcode: 'barcode', lane: Lane(null)),
    CheckInTransactionTicketAction(
        step: CheckInOutTransactionTicketActionStep.Started),
    CheckOutTransactionTicketAction(
        uuid: 'uuid', step: CheckInOutTransactionTicketActionStep.Started)
  ]);
}

void main() {
  test('my', () {
    expect(() => TicketAction.fromJson({}), throwsException);
  });

  test('testTicketActions', () {
    final tas = testTicketActions();
    final str = json.encode(tas);
    final ref = TicketActions.fromJson(json.decode(str));
    expect(ref, tas);
  });

  test('AmbiguousAction', () {
    final aa = AmbiguousAction(barcode: 'barcode');
    final str = json.encode(aa.toJson());
    AmbiguousAction ref = TicketAction.fromJson(json.decode(str));
    expect(ref is AmbiguousAction, true);
    expect(ref.barcode, 'barcode');
  });

  test('BarcodeScannedTicketAction', () {
    final aa = BarcodeScannedTicketAction(barcode: 'barcode', lane: Lane(null));
    final str = json.encode(aa);
    BarcodeScannedTicketAction ref = TicketAction.fromJson(json.decode(str));
    expect(ref is BarcodeScannedTicketAction, true);
    expect(ref.barcode, 'barcode');
    expect(ref.lane == aa.lane, true);
  });

  test('enum str -> enum', () {
    expect(fromStringCheckInOutTransactionTicketActionStep('xxx'),
        CheckInOutTransactionTicketActionStep.Error);
    expect(fromStringCheckInOutTransactionTicketActionStep('Error'),
        CheckInOutTransactionTicketActionStep.Error);
    expect(fromStringCheckInOutTransactionTicketActionStep('Started'),
        CheckInOutTransactionTicketActionStep.Started);
    expect(fromStringCheckInOutTransactionTicketActionStep('Completed'),
        CheckInOutTransactionTicketActionStep.Completed);
  });

  test('enum enum -> str', () {
    expect(
        asStringCheckInOutTransactionTicketActionStep(
            CheckInOutTransactionTicketActionStep.Error),
        'Error');
    expect(
        asStringCheckInOutTransactionTicketActionStep(
            CheckInOutTransactionTicketActionStep.Completed),
        'Completed');
    expect(
        asStringCheckInOutTransactionTicketActionStep(
            CheckInOutTransactionTicketActionStep.Started),
        'Started');
  });

  test('CheckInTransactionTicketAction', () {
    final my = CheckInTransactionTicketAction(
        step: CheckInOutTransactionTicketActionStep.Started);
    final str = json.encode(my);
    CheckInTransactionTicketAction ref =
        TicketAction.fromJson(json.decode(str));
    expect(ref is CheckInTransactionTicketAction, true);
    expect(ref.step, CheckInOutTransactionTicketActionStep.Started);
  });

  test('CheckOutTransactionTicketAction', () {
    final my = CheckOutTransactionTicketAction(
        uuid: 'uuid', step: CheckInOutTransactionTicketActionStep.Started);
    final str = json.encode(my);
    CheckOutTransactionTicketAction ref =
        TicketAction.fromJson(json.decode(str));
    expect(ref is CheckOutTransactionTicketAction, true);
    expect(ref.step, CheckInOutTransactionTicketActionStep.Started);
    expect(ref.uuid, 'uuid');
  });

  test('CheckInTransactionTicketAction 200 run', () async {
    final my = CheckInTransactionTicketAction(
        step: CheckInOutTransactionTicketActionStep.Started);
    final res = testCheckedInResponse();
    await my.run(
        url: 'url',
        ticketId: 474,
        client: MockClient((request) async {
          expect(request.url.toString(), 'url');
          expect(request.headers['Accept'], 'application/json');
          expect(request.headers['Content-Type'].startsWith('application/json'),
              true);
          final req = json.decode(request.body);
          expect(req['checkin']['ticket_id'], 474);
          return Response(json.encode(res), 200);
        }));
    expect(my.step, CheckInOutTransactionTicketActionStep.Completed);
    expect(my.error, null);
    expect(my.res != null, true);
    expect(res, CheckedInResponse.fromJson(json.decode(my.res.body)));
  });

  test('CheckInTransactionTicketAction 300 run', () async {
    final my = CheckInTransactionTicketAction(
        step: CheckInOutTransactionTicketActionStep.Started);
    final res = testCheckedInResponse();
    await my.run(
        url: 'url',
        ticketId: 474,
        client: MockClient((request) async {
          expect(request.url.toString(), 'url');
          expect(request.headers['Accept'], 'application/json');
          expect(request.headers['Content-Type'].startsWith('application/json'),
              true);
          final req = json.decode(request.body);
          expect(req['checkin']['ticket_id'], 474);
          return Response(json.encode(res), 300);
        }));
    expect(my.step, CheckInOutTransactionTicketActionStep.Error);
    expect(my.error != null, true);
    expect(my.res != null, true);
  });
  test('CheckInTransactionTicketAction error run', () async {
    final my = CheckInTransactionTicketAction(
        step: CheckInOutTransactionTicketActionStep.Started);
    await my.run(
        url: 'url',
        ticketId: 474,
        client: MockClient((request) async {
          expect(request.url.toString(), 'url');
          expect(request.headers['Accept'], 'application/json');
          expect(request.headers['Content-Type'].startsWith('application/json'),
              true);
          final req = json.decode(request.body);
          expect(req['checkin']['ticket_id'], 474);
          throw Exception('Wech');
        }));
    expect(my.step, CheckInOutTransactionTicketActionStep.Error);
    expect(my.error != null, true);
    expect(my.res == null, true);
  });

  test('CheckOutTransactionTicketAction 200 run', () async {
    final my = CheckOutTransactionTicketAction(
        uuid: 'uuid', step: CheckInOutTransactionTicketActionStep.Started);
    final res = testCheckedInResponse();
    await my.run(
        url: 'url',
        client: MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.toString(), 'url');
          return Response(json.encode(res), 200);
        }));
    expect(my.step, CheckInOutTransactionTicketActionStep.Completed);
    expect(my.error, null);
    expect(my.res != null, true);
    expect(res, CheckedInResponse.fromJson(json.decode(my.res.body)));
  });

  test('CheckOutTransactionTicketAction 300 run', () async {
    final my = CheckOutTransactionTicketAction(
        uuid: 'uuid', step: CheckInOutTransactionTicketActionStep.Started);
    final res = testCheckedInResponse();
    await my.run(
        url: 'url',
        client: MockClient((request) async {
          expect(request.url.toString(), 'url');
          expect(request.method, 'DELETE');
          return Response(json.encode(res), 300);
        }));
    expect(my.step, CheckInOutTransactionTicketActionStep.Error);
    expect(my.error != null, true);
    expect(my.res.statusCode, 300);
  });
  test('CheckOutTransactionTicketAction error run', () async {
    final my = CheckOutTransactionTicketAction(
        uuid: 'uuid', step: CheckInOutTransactionTicketActionStep.Started);
    await my.run(
        url: 'url',
        client: MockClient((request) async {
          expect(request.url.toString(), 'url');
          expect(request.method, 'DELETE');
          throw Exception('Wech');
        }));
    expect(my.step, CheckInOutTransactionTicketActionStep.Error);
    expect(my.error != null, true);
    expect(my.res == null, true);
  });
}
