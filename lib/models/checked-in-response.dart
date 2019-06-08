import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class CheckedInResponse {
  final int id;
  final int checkInListId;
  final int ticketId;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final String uuidBin;
  final String uuid;

  CheckedInResponse(
      {@required int id,
      @required int checkinListId,
      @required int ticketId,
      String createdAt,
      String updatedAt,
      String deletedAt,
      @required String uuidBin,
      @required String uuid})
      : id = id,
        checkInListId = checkinListId,
        ticketId = ticketId,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt,
        uuidBin = uuidBin,
        uuid = uuid;

  @override
  bool operator ==(o) {
    return o is CheckedInResponse &&
     o.id == id &&
     o.checkInListId == checkInListId &&
     o.ticketId == ticketId &&
     o.createdAt == createdAt &&
     o.updatedAt == updatedAt &&
     o.deletedAt == deletedAt &&
     o.uuid == uuid &&
     o.uuidBin == uuidBin;
  }

  static CheckedInResponse fromJson(dynamic my) {
    return CheckedInResponse(
        id: my['id'],
        checkinListId: my['checkin_list_id'],
        ticketId: my['ticket_id'],
        createdAt: my['created_at'],
        updatedAt: my['updated_at'],
        uuidBin: my['uuid_bin'],
        deletedAt: my['deleted_at'],
        uuid: my['uuid']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'checkin_list_id': checkInListId,
        'ticket_id': ticketId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'uuid_bin': uuidBin,
        'uuid': uuid
      };

  static CheckedInResponse fromResponse(http.Response res) {
    final my = json.decode(res.body);
    return CheckedInResponse.fromJson(my);
  }
}
