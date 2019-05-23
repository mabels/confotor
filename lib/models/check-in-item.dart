
class CheckInItem {
  int  id;
  String uuid;
  int ticket_id;
  DateTime created_at;
  DateTime updated_at;
  DateTime deleted_at;

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

  update(CheckInItem up) {
    id = up.id;
    uuid = up.uuid;
    ticket_id = up.ticket_id;
    created_at = up.created_at;
    updated_at = up.updated_at;
    deleted_at = up.deleted_at;
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