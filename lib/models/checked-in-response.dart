import 'dart:convert';

import 'package:http/http.dart' as http;

class CheckedInResponse {
  int id;
  int checkin_list_id;
  int ticket_id;
  String created_at;
  String updated_at;
  String uuid_bin;
  String deleted_at;
  String uuid;

  static CheckedInResponse fromResponse(http.Response res) {
    print('CheckedInResponse:${res.body}');
    final cir = new CheckedInResponse();
    final my = json.decode(res.body);
    cir.id = my['id'];
    cir.checkin_list_id = my['checkin_list_id'];
    cir.ticket_id = my['ticket_id'];
    cir.created_at = my['created_at'];
    cir.updated_at = my['updated_at'];
    cir.uuid_bin = my['uuid_bin'];
    cir.deleted_at = my['deleted_at'];
    cir.uuid = my['uuid'];
    return cir;
  }

}