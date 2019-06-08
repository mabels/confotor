import 'package:confotor/models/conference.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'check-in-list-item.dart';

part 'conferences.g.dart';

// This is the class used by rest of your codebase
class Conferences extends ConferencesBase with _$Conferences {
  Conferences({@required List<Conference> conferences})
      : super(conferences: conferences);

  static Conferences fromJson(dynamic json) {
    List<dynamic> o = json;
    if (!(o is List)) {
      o = [];
    }
    final confs = Conferences(
        conferences: o.map((conf) => Conference.fromJson(conf)).toList());
    return confs;
  }
}

// The store-class
abstract class ConferencesBase with Store {
  final ObservableList<Conference> _conferences;

  // get isEmpty => Computed<bool>(() => conferences.value.isEmpty)();

  ConferencesBase({@required List<Conference> conferences})
      : _conferences = ObservableList.of(conferences);

  @computed
  bool get isEmpty => _conferences.isEmpty;

  @computed
  bool get isNotEmpty => _conferences.isNotEmpty;


  @computed
  Conference get first => _conferences.first;

  @computed
  Conference get last => _conferences.last;

  @computed
  Iterable<Conference> get values => _conferences.toList();

  @computed
  int get length => _conferences.length;

  @action
  updateFromUrl(String url, { BaseClient client }) async {
    final cil = _conferences.firstWhere((i) => i.checkInList.url == url,
        orElse: () => null);
    try {
      final checkInList = await CheckInList.fetch(url, client: client);
      if (cil == null) {
        _conferences.add(
            Conference(checkInList: checkInList, ticketAndCheckInsList: []));
      } else {
        cil.error = null;
        cil.checkInList.item = checkInList.item;
      }
    } catch (e) {
      if (cil == null) {
        _conferences.add(Conference(
            error: e,
            checkInList: CheckInList(url: url, checkInListItem: null),
            ticketAndCheckInsList: null));
      } else {
        cil.error = e;
      }
    }
  }

  toJson() => _conferences.toList();

}
