
import 'package:confotor/models/check-in-item.dart';

class CheckInItemsStore {
  final Map<String /*uuid*/, CheckInItem> _checkInItems = Map();



  get length {
    return _checkInItems.length;
  }

  update(List<CheckInItem> oth) {
    oth.forEach((jsonItem) {
      final item = CheckInItem.fromJson(jsonItem);
      _checkInItems.putIfAbsent(item.uuid, () => item).update(item);
    });
    return this;
  }

  toList() => _checkInItems.values.toList();

  toJson() => _checkInItems.values.toList();
}
