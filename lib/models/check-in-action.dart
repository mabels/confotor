
class CheckInAction {
  final String  id;

  CheckInAction({id}): id = id;

  update(CheckInAction oth) {
    if (!(id == oth.id)) {
      throw Exception("Update Object with non matching uuid");
    }
  }

  static CheckInAction fromJson(dynamic json) {
    return CheckInAction(id: json['id']).updateFromJson(json);
  }

  updateFromJson(dynamic json) {
    return this;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
  };

}