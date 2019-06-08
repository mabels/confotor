import 'package:path/path.dart';

abstract class ConferenceKey {
  final String url;

  ConferenceKey(String url): url = url;

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
