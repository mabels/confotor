import 'dart:convert';
import 'package:confotor/models/conference.dart';
import 'package:http/http.dart' as http;

class CheckInListItem extends ConferenceKey {
  String url;
  String event_title;
  String expires_at;
  String expires_at_timestamp;
  String tickets_url;
  String checkin_list_url;
  String sync_url;
  int total_pages;
  int total_entries;

  static Future<CheckInListItem> fetch(String url) async {
    var response = await http.get(url);
    if (200 <= response.statusCode && response.statusCode < 300) {
      final jsonResponse = json.decode(response.body);
      return CheckInListItem.fromJson(jsonResponse);
    }
    throw new Exception('CheckInListItem:fetch:$url');
  }

  static CheckInListItem fromJson(dynamic json) {
    return CheckInListItem().updateFromJson(json);
  }

  updateFromJson(dynamic json) {
    url = json['url'];
    event_title = json['event_title'];
    expires_at = json['expires_at'];
    expires_at_timestamp = json['expires_at_timestamp'];
    tickets_url = json['tickets_url'];
    checkin_list_url = json['checkin_list_url'];
    sync_url = json['sync_url'];
    total_pages = json['total_pages'];
    total_entries = json['total_entries'];
    return this;
  }

  get shortEventTitle {
    return event_title.split(" ").first;
  }

  Map<String, dynamic> toJson() {
    return {
        "url": url,
        "event_title": event_title,
        "expires_at": expires_at,
        "expires_at_timestamp": expires_at_timestamp,
        "tickets_url": tickets_url,
        "checkin_list_url": checkin_list_url,
        "sync_url": sync_url,
        "total_pages": total_pages,
        "total_entries": total_entries,
      };
  }


}
