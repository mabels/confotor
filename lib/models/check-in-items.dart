import 'check-in-item.dart';

class CheckInItems {
  final Map<String /*uuid*/, CheckInItem> _checkInItems = Map();

  get length {
    return _checkInItems.length;
  }

  update(CheckInItems oth) {
    throw Exception("TOTOTOT");
  }

  updateFromJson(dynamic json) {
    List<dynamic> checkInItems = json;
    if (checkInItems == null) {
      checkInItems = [];
    }
    checkInItems.forEach((jsonItem) {
      final item = CheckInItem.fromJson(jsonItem);
      _checkInItems.putIfAbsent(item.uuid, () => item).update(item);
    });
    return this;
  }

  toJson() => _checkInItems.values.toList();
}
