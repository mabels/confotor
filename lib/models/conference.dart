import 'package:confotor/models/ticket-store.dart';
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
  final TicketStore ticketStore;

  Conference({@required checkInListItem, @required ticketStore}):
    checkInListItem = checkInListItem,
    ticketStore = ticketStore;


  static fromJson(dynamic json) {
    return Conference(checkInListItem: CheckInListItem.fromJson(json['checkInListItem']),
                      ticketStore: TicketStore.fromJson(json['ticketStore']));
  }

  updateFromJson(dynamic json) {
    checkInListItem.updateFromJson(json['checkInListItem']);
    ticketStore.updateFromJson(json['ticketStore']);
  }

  @override
  get url => checkInListItem.url;

  toJson() => {
    "checkInListItem": checkInListItem.toJson(),
    "ticketStore": ticketStore.toJson()
  };

}