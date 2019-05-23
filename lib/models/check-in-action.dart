
class CheckInAction {
  final String  id;

  CheckInAction({id}): id = id;

  static CheckInAction fromJson(dynamic json) {
    return CheckInAction(id: json['id']); // .updateFromJson(json);
  }

  update(CheckInAction oth) {
    return this;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
  };

}