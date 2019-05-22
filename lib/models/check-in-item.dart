
class CheckInItem {
  int  id;
  String uuid;
  int ticket_id;
  DateTime created_at;
  DateTime updated_at;
  DateTime deleted_at;

  update(CheckInItem oth) {
    if (!(uuid == oth.uuid && id == oth.id && ticket_id == oth.ticket_id)) {
      throw Exception("Update Object with non matching uuid");
    }
    created_at = oth.created_at;
    updated_at = oth.updated_at;
    deleted_at = oth.deleted_at;
  }

  static CheckInItem fromJson(dynamic json) {
    final ret = CheckInItem();
    ret.id = json['id'];
    ret.uuid = json['uuid'];
    ret.ticket_id = json['ticket_id'];
    ret.created_at = json["created_at"] == null ? null : DateTime.parse(json["created_at"]);
    ret.updated_at = json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]);
    ret.deleted_at = json["deleted_at"] == null ? null : DateTime.parse(json["deleted_at"]);
    return ret;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "ticket_id": ticket_id,
    "created_at": created_at != null ? created_at.toIso8601String() : null,
    "updated_at": deleted_at != null ? updated_at.toIso8601String() : null,
    "deleted_at": deleted_at != null ? deleted_at.toIso8601String() : null
  };

  DateTime get maxDate {
    var max = created_at;
    if (updated_at != null && updated_at.compareTo(max) > 0) {
      max = updated_at;
    }
    if (deleted_at != null && deleted_at.compareTo(max) > 0) {
      max = deleted_at;
    }
    return max;
  }
}