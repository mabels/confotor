import 'dart:io';

import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/msgs/msgs.dart';

class Conferences {
  final List<Conference> conferences = [];
  Conferences fromJson(dynamic json) {
    final confs = Conferences();
    List<dynamic> o = json;
    o.forEach((conf) => conferences.add(Conference.fromJson(conf)));
    return confs;
  }

  toJson() => conferences;

}
