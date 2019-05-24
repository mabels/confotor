import 'package:confotor/models/conference.dart';
import 'package:confotor/msgs/confotor-msg.dart';

const List<Conference> conferencesEmpty = [];
class Conferences extends ConfotorMsg {
  final List<Conference> conferences;

  Conferences({List<Conference> conferences: conferencesEmpty}): conferences = conferences;

  static Conferences fromJson(dynamic json) {
    final confs = Conferences();
    List<dynamic> o = json;
    o.forEach((conf) => confs.conferences.add(Conference.fromJson(conf)));
    return confs;
  }

  get isEmpty => conferences.isEmpty;

  toJson() => conferences;

}
