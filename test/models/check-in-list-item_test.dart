import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:test_api/test_api.dart';

CheckInList testCheckInList({
  String url,
  String eventTitle: 'qqq',
}) {
  if (url == null) {
    url = 'test://url';
  }
  return CheckInList(
      url: url,
      checkInListItem: CheckInListItem(
          eventTitle: eventTitle,
          expiresAt: 'ppp',
          expiresAtTimestamp: 'ooo',
          ticketsUrl: 'uuu',
          checkinListUrl: 'yyy',
          syncUrl: 'xxx',
          totalPages: 5,
          totalEntries: 4));
}

void main() {
  test("Serialize", () {
    final cil = testCheckInList();
    final str = json.encode(cil);
    final refCil = CheckInList.fromJson(json.decode(str));
    expect(cil.url, refCil.url);
    expect(cil.item.value.eventTitle, refCil.item.value.eventTitle);
    expect(cil.item.value.expiresAt, refCil.item.value.expiresAt);
    expect(cil.item.value.expiresAtTimestamp, refCil.item.value.expiresAtTimestamp);
    expect(cil.item.value.ticketsUrl, refCil.item.value.ticketsUrl);
    expect(cil.item.value.checkinListUrl, refCil.item.value.checkinListUrl);
    expect(cil.item.value.syncUrl, refCil.item.value.syncUrl);
    expect(cil.item.value.totalPages, refCil.item.value.totalPages);
    expect(cil.item.value.totalEntries, refCil.item.value.totalEntries);
  });
  test('shortEventTitle', () {
    expect(testCheckInList(eventTitle: 'qqq qqq').item.value.shortEventTitle, 'qqq');
    expect(testCheckInList(eventTitle: 'qqq').item.value.shortEventTitle, 'qqq');
  });

  test('fetch', () async {
    final refCil = testCheckInList();
    final cil =
        await CheckInList.fetch('test://url', client: MockClient((request) async {
      final encode = json.encode(refCil.item);
      return Response(encode, 200);
    }));
    expect(cil.url, 'test://url');

    expect(cil.item.value.eventTitle, refCil.item.value.eventTitle);
    expect(cil.item.value.expiresAt, refCil.item.value.expiresAt);
    expect(cil.item.value.expiresAtTimestamp, refCil.item.value.expiresAtTimestamp);
    expect(cil.item.value.ticketsUrl, refCil.item.value.ticketsUrl);
    expect(cil.item.value.checkinListUrl, refCil.item.value.checkinListUrl);
    expect(cil.item.value.syncUrl, refCil.item.value.syncUrl);
    expect(cil.item.value.totalPages, refCil.item.value.totalPages);
    expect(cil.item.value.totalEntries, refCil.item.value.totalEntries);
  });
}
