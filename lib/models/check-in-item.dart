import 'package:meta/meta.dart';

class CheckInItem {
  final int id;
  final String uuid;
  final int ticketId;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;

  CheckInItem({
      @required int id,
      @required String uuid,
      @required int ticketId,
      @required DateTime createdAt,
      DateTime updatedAt,
      DateTime deletedAt})
      : id = id,
        uuid = uuid,
        ticketId = ticketId,
        createdAt = createdAt,
        updatedAt = updatedAt,
        deletedAt = deletedAt;

  bool operator ==(o) {
    return o is CheckInItem &&
       o.id == id &&
       o.uuid == uuid &&
       o.ticketId == ticketId &&
       o.createdAt == createdAt &&
       o.updatedAt == updatedAt &&
       o.deletedAt == deletedAt;
  }

  static CheckInItem fromJson(dynamic json) {
    return CheckInItem(
        id: json['id'],
        uuid: json['uuid'],
        ticketId: json['ticket_id'],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"] == null
            ? null
            : DateTime.parse(json["deleted_at"]));
  }

  update(CheckInItem up) {
    updatedAt = up.updatedAt;
    deletedAt = up.deletedAt;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "ticket_id": ticketId,
        "created_at": createdAt != null ? createdAt.toIso8601String() : null,
        "updated_at": updatedAt != null ? updatedAt.toIso8601String() : null,
        "deleted_at": deletedAt != null ? deletedAt.toIso8601String() : null
      };

  DateTime get maxDate {
    var max = createdAt;
    if (updatedAt != null) {
      if (max == null || updatedAt.compareTo(max) > 0) {
        max = updatedAt;
      } 
    }
    if (deletedAt != null) {
      if (max == null || deletedAt.compareTo(max) > 0) {
        max = deletedAt;
      }
    }
    return max;
  }
}
