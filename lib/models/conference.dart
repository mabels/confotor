import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'check-in-list-item.dart';

abstract class ConferenceKey {
  final String url;

  ConferenceKey(String url): url = url {
    // print('ConferenceKey:$url');
  }

  String get listId {
    final url = Uri.parse(this.url);
    return basename(url.path).split('.').first;
    // https://ti.to/jsconfeu/jsconf-eu-x-2019/checkin_lists/xxxxxxxxx.json;
  }

  String ticketsUrl(int page) {
    // https://ti.to/jsconfeu/jsconf-eu-x-2019/checkin_lists/hello/tickets.json
    return 'https://checkin.tito.io/checkin_lists/$listId/tickets?page=$page';
  }

  String checkInUrl({since: 0, page: 0}) {
    return 'https://checkin.tito.io/checkin_lists/$listId/checkins?since=$since&page=$page';
  }

  String checkOutUrl(String uuid) {
    return "https://checkin.tito.io/checkin_lists/$listId/checkins/$uuid";
  }
}

class Conference {
  final CheckInList checkInList;
  final List<TicketAndCheckIns> ticketAndCheckInsList;

  Conference({@required CheckInList checkInList, @required List<TicketAndCheckIns> ticketAndCheckInsList}):
    checkInList = checkInList,
    ticketAndCheckInsList = ticketAndCheckInsList;

  get checkInItemLength {
    final i = ticketAndCheckInsList.map((t) => t.checkInItems.length);
    if (i.isEmpty) {
      return 0;
    }
    return i.reduce((a, b) => a + b);
  }

  static Conference fromJson(dynamic json) {
    final List<TicketAndCheckIns> ticketAndCheckInsList = [];
    if (json['ticketAndCheckInsList'] != null) {
      List<dynamic> my = json['ticketAndCheckInsList'];
      my.forEach((j) => ticketAndCheckInsList.add(TicketAndCheckIns.fromJson(j)));
    }
    return Conference(checkInList: CheckInList.fromJson(json['checkInListItem']),
                      ticketAndCheckInsList: ticketAndCheckInsList);
  }

  get url => checkInList.url;

  toJson() => {
    "checkInListItem": checkInList,
    "ticketStore": ticketAndCheckInsList
  };


}