import 'package:confotor/models/conference.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import 'check-in-list-item.dart';

class Conferences extends ConfotorMsg {
  final ObservableList<Conference> conferences;

  // get isEmpty => Computed<bool>(() => conferences.value.isEmpty)();

  Conferences({@required List<Conference> conferences}): 
    conferences = ObservableList.of(conferences);


  updateFromUrl(String url) {
    final cil = conferences.firstWhere((i) => i.checkInList.url == url);
    CheckInList.fetch(url).then((checkInList) => Action(() {
      if (cil == null) {
        conferences.add(Conference(checkInList: checkInList,
          ticketAndCheckInsList: []));
      } else {
        cil.error.value = null;
        cil.checkInList.item.value = checkInList.item.value;
      }
    })()).catchError((e) {
      if (cil == null) {
        conferences.add(Conference(
            error: e, checkInList: null, ticketAndCheckInsList: null
        ));
      } else {
        cil.error.value = e;
      }

    });
  }

  static Conferences fromJson(dynamic json) {
    List<dynamic> o = json;
    if (!(o is List)) {
      o = [];
    }
    final confs = Conferences(conferences: o.map((conf) =>
      Conference.fromJson(conf))
      .toList());
    return confs;
  }

  toJson() => conferences.toList();

}
