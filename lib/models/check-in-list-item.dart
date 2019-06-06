import 'dart:convert';
import 'dart:io';
import 'package:confotor/models/conference-key.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'fix-http-client.dart';

part 'check-in-list-item.g.dart';

class CheckInListItem {
  final String eventTitle;
  final String expiresAt;
  final String expiresAtTimestamp;
  final String ticketsUrl;
  final String checkinListUrl;
  final String syncUrl;
  final int totalPages;
  final int totalEntries;

  CheckInListItem(
      {
      @required String eventTitle,
      @required String expiresAt,
      @required String expiresAtTimestamp,
      @required String ticketsUrl,
      @required String checkinListUrl,
      @required String syncUrl,
      @required int totalPages,
      @required int totalEntries})
      : eventTitle = eventTitle,
        expiresAt = expiresAt,
        expiresAtTimestamp = expiresAtTimestamp,
        ticketsUrl = ticketsUrl,
        checkinListUrl = checkinListUrl,
        syncUrl = syncUrl,
        totalPages = totalPages,
        totalEntries = totalEntries;


  bool operator ==(o) {
    return o is CheckInListItem &&
    o.eventTitle == eventTitle &&
    o.expiresAt == expiresAt &&
    o.expiresAtTimestamp == expiresAtTimestamp &&
    o.ticketsUrl == ticketsUrl &&
    o.checkinListUrl == checkinListUrl &&
    o.syncUrl == syncUrl &&
    o.totalPages == totalPages &&
    o.totalEntries == totalEntries;
  }


  static CheckInListItem fromJson(dynamic json) {
    return CheckInListItem(
        eventTitle: json['event_title'],
        expiresAt: json['expires_at'],
        expiresAtTimestamp: json['expires_at_timestamp'],
        ticketsUrl: json['tickets_url'],
        checkinListUrl: json['checkin_list_url'],
        syncUrl: json['sync_url'],
        totalPages: json['total_pages'],
        totalEntries: json['total_entries']);
  }

  String get shortEventTitle => eventTitle.split(" ").first;

  Map<String, dynamic> toJson() {
    return {
      "event_title": eventTitle,
      "expires_at": expiresAt,
      "expires_at_timestamp": expiresAtTimestamp,
      "tickets_url": ticketsUrl,
      "checkin_list_url": checkinListUrl,
      "sync_url": syncUrl,
      "total_pages": totalPages,
      "total_entries": totalEntries,
    };
  }
}

class CheckInList extends CheckInListBase with _$CheckInList {

  CheckInList({@required String url,
               @required CheckInListItem checkInListItem
              }): super(
                url: url,
                checkInListItem: checkInListItem
              );

  static CheckInList fromJson(dynamic json) {
    return CheckInList(
        url: json['url'],
        checkInListItem: CheckInListItem.fromJson(json['checkInListItem']));
  }


  static Future<CheckInList> fetch(String url, { BaseClient client }) async {
    try {
      final parsed = Uri.parse(url);
      // print('fetch:$url:$parsed');
      if (parsed.scheme == null || parsed.scheme.isEmpty) {
        throw Exception("uri fetch:$url");
      }
    } catch (e) {
      // print('fetch:$url:$e');
      throw e;
    }
    final response = await fixHttpClient(client).get(url);
    if (200 <= response.statusCode && response.statusCode < 300) {
      final jsonResponse = json.decode(response.body);
      return CheckInList(
        url: url,
        checkInListItem: CheckInListItem.fromJson(jsonResponse)
      );
    }
    throw Exception('CheckInList:fetch:${response.statusCode}:$url');
  }
}

abstract class CheckInListBase extends ConferenceKey with Store {
  final Observable<CheckInListItem> _item;

  CheckInListBase({@required String url,
               @required CheckInListItem checkInListItem
              }):
              _item = Observable(checkInListItem),
              super(url);

  @computed
  CheckInListItem get item => _item.value;

  @computed
  set item(CheckInListItem i) => _item.value = i;

  bool operator ==(dynamic o) {
    return (o is CheckInList || o is CheckInListBase)
       && url == o.url && _item.value == o._item.value;
  }

  Map<String, dynamic> toJson() => {
    "url": url,
    "checkInListItem": _item.value
  };


}