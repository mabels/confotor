import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/stores/ticket-store.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'check-in-list-item.dart';

abstract class ConferenceKey {
  String get url;

  String get listId {
    final url = Uri.parse(this.url);
    return basename(dirname(url.path));
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

class Conference extends ConferenceKey {
  final CheckInListItem checkInListItem;
  final List<TicketAndCheckIns> ticketAndCheckInsList;

  Conference({@required checkInListItem, @required ticketAndCheckInsList}):
    checkInListItem = checkInListItem,
    ticketAndCheckInsList = ticketAndCheckInsList;


  static fromJson(dynamic json) {
    final List<TicketAndCheckIns> ticketAndCheckInsList = [];
    if (json['ticketAndCheckInsList'] != 0) {
      List<dynamic> my = json['ticketAndCheckInsList'];
      my.forEach((j) => ticketAndCheckInsList.add(TicketAndCheckIns.fromJson(j)));
    }
    return Conference(checkInListItem: CheckInListItem.fromJson(json['checkInListItem']),
                      ticketAndCheckInsList: ticketAndCheckInsList);
  }

  @override
  get url => checkInListItem.url;

  toJson() => {
    "checkInListItem": checkInListItem.toJson(),
    "ticketStore": ticketAndCheckInsList
  };


}