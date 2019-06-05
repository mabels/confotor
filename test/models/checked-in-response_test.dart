import 'dart:convert';

import 'package:confotor/models/checked-in-response.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:test_api/test_api.dart';

testCheckedInResponse() {
  return CheckedInResponse(
      id: 4711,
      checkinListId: 4411,
      ticketId: 5566,
      createdAt: 'createdAt',
      updatedAt: 'updatedAt',
      deletedAt: 'deletedAt',
      uuidBin: 'uuidBin',
      uuid: 'uuid'
    );
}

void main() {
  test("Serialize", () {
    final cir = testCheckedInResponse();
    final str = json.encode(cir);
    var refCir = CheckedInResponse.fromJson(json.decode(str));
    expect(cir.id, refCir.id);
    expect(cir.checkinListId, refCir.checkinListId);
    expect(cir.ticketId, refCir.ticketId);
    expect(cir.createdAt, refCir.createdAt);
    expect(cir.updatedAt, refCir.updatedAt);
    expect(cir.deletedAt, refCir.deletedAt);
    expect(cir.uuid, refCir.uuid);
    expect(cir.uuidBin, refCir.uuidBin);
    refCir = CheckedInResponse.fromResponse(Response(str, 200));
    expect(cir.id, refCir.id);
    expect(cir.checkinListId, refCir.checkinListId);
    expect(cir.ticketId, refCir.ticketId);
    expect(cir.createdAt, refCir.createdAt);
    expect(cir.updatedAt, refCir.updatedAt);
    expect(cir.deletedAt, refCir.deletedAt);
    expect(cir.uuid, refCir.uuid);
    expect(cir.uuidBin, refCir.uuidBin);
  });

}