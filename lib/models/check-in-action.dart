
import 'package:meta/meta.dart';

class CheckInAction {
  final String  id;
  final String  ticket_id;

  CheckInAction({@required id, @required ticket_id}): id = id, ticket_id = ticket_id;

  static CheckInAction fromJson(dynamic json) {
    return CheckInAction(id: json['id'], ticket_id: json['ticket_id']); // .updateFromJson(json);
  }

  update(CheckInAction oth) {
    return this;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
  };

}