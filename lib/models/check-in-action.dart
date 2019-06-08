
import 'package:meta/meta.dart';

class CheckInAction {
  final String  id;
  final int ticketId;

  CheckInAction({@required id, @required int ticketId}):
        id = id,
        ticketId = ticketId;

  static CheckInAction fromJson(dynamic json) {
    return CheckInAction(id: json['id'], ticketId: json['ticket_id']);
  }

  // .updateFromJson(json);
  // update(CheckInAction oth) {
  //   return this;
  // }

  Map<String, dynamic> toJson() => {
    "id": id,
    "ticket_id": ticketId
  };

}