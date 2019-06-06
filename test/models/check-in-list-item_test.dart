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
    expect(cil.item..eventTitle, refCil.item..eventTitle);
    expect(cil.item..expiresAt, refCil.item..expiresAt);
    expect(cil.item..expiresAtTimestamp, refCil.item..expiresAtTimestamp);
    expect(cil.item..ticketsUrl, refCil.item..ticketsUrl);
    expect(cil.item..checkinListUrl, refCil.item..checkinListUrl);
    expect(cil.item..syncUrl, refCil.item..syncUrl);
    expect(cil.item..totalPages, refCil.item..totalPages);
    expect(cil.item..totalEntries, refCil.item..totalEntries);
  });
  test('shortEventTitle', () {
    expect(testCheckInList(eventTitle: 'qqq qqq').item.shortEventTitle, 'qqq');
    expect(testCheckInList(eventTitle: 'qqq').item.shortEventTitle, 'qqq');
  });

  test('fetch', () async {
    final refCil = testCheckInList();
    final cil =
        await CheckInList.fetch('test://url', client: MockClient((request) async {
      final encode = json.encode(refCil.item);
      return Response(encode, 200);
    }));
    expect(cil.url, 'test://url');

    expect(cil.item.eventTitle, refCil.item.eventTitle);
    expect(cil.item.expiresAt, refCil.item.expiresAt);
    expect(cil.item.expiresAtTimestamp, refCil.item.expiresAtTimestamp);
    expect(cil.item.ticketsUrl, refCil.item.ticketsUrl);
    expect(cil.item.checkinListUrl, refCil.item.checkinListUrl);
    expect(cil.item.syncUrl, refCil.item.syncUrl);
    expect(cil.item.totalPages, refCil.item.totalPages);
    expect(cil.item.totalEntries, refCil.item.totalEntries);
  });
}
