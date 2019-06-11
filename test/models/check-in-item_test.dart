import 'dart:convert';

import 'package:confotor/models/check-in-item.dart';
import 'package:test_api/test_api.dart';

CheckInItem testCheckInItem({
  int ticketId,
  String uuid,
  DateTime createdAt,
  DateTime updatedAt,
  DateTime deletedAt
}) {
  return CheckInItem(
        id: 4711,
        uuid: uuid == null ? 'uuid$ticketId' : uuid,
        ticketId: ticketId == null ? 44 : ticketId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt);  
}

void main() {
  test('maxDate null, null, null', () {
    final cia =
        CheckInItem(id: 4711, uuid: 'uuid', ticketId: 44, createdAt: null);
    expect(cia.maxDate, null);
  });
  test('maxDate date, null, null', () {
    var cia = testCheckInItem(
        createdAt: DateTime.now());
    expect(cia.maxDate, cia.createdAt);

    cia = testCheckInItem(
        updatedAt: DateTime.now(),
        createdAt: null);
    expect(cia.maxDate, cia.updatedAt);

    cia = testCheckInItem(
        deletedAt: DateTime.now(),
        createdAt: null);
    expect(cia.maxDate, cia.deletedAt);
  });

  test('maxDate date, date, null', () {
    var cia = testCheckInItem(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
    expect(cia.maxDate, cia.updatedAt);

    cia = testCheckInItem(
        createdAt: DateTime.now(),
        deletedAt: DateTime.now());
    expect(cia.maxDate, cia.deletedAt);

    cia = testCheckInItem(
        createdAt: null,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now());
    expect(cia.maxDate, cia.deletedAt);
  });

  test('maxDate date, date, date', () {
    final cia = testCheckInItem(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now());
    expect(cia.maxDate, cia.deletedAt);
  });

  test('Serialize', () {
    final cia = testCheckInItem(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now());
    final str = json.encode(cia);
    // print('Serialize:$str');
    final refCia = CheckInItem.fromJson(json.decode(str));
    expect(cia.id, refCia.id);
    expect(cia.uuid, refCia.uuid);
    expect(cia.ticketId, refCia.ticketId);
    expect(cia.createdAt, refCia.createdAt);
    expect(cia.updatedAt, refCia.updatedAt);
    expect(cia.deletedAt, refCia.deletedAt);
  });

  test('Serialize Null', () {
    final cia = testCheckInItem(
        createdAt: null,
        updatedAt: null,
        deletedAt: null);
    final str = json.encode(cia);
    // print('Serialize:$str');
    final refCia = CheckInItem.fromJson(json.decode(str));
    expect(cia.id, refCia.id);
    expect(cia.uuid, refCia.uuid);
    expect(cia.ticketId, refCia.ticketId);
    expect(cia.createdAt, refCia.createdAt);
    expect(cia.updatedAt, refCia.updatedAt);
    expect(cia.deletedAt, refCia.deletedAt);
  });


}
