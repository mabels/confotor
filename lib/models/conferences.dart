import 'package:confotor/models/conference.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:meta/meta.dart';

// const List<Conference> conferencesEmpty = [];
class Conferences extends ConfotorMsg {
  final List<Conference> conferences;

  Conferences({@required List<Conference> conferences}): conferences = conferences;

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

  get isEmpty => conferences.isEmpty;

  toJson() => conferences;

}
