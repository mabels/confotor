
import 'package:confotor/models/check-in-item.dart';

class CheckInItemsStore {
  final Map<String /*uuid*/, CheckInItem> _checkInItems = Map();

  get length {
    return _checkInItems.length;
  }

  update(List<CheckInItem> oth) {
    oth.forEach((cii) {
      // final item = CheckInItem.fromJson(jsonItem);
      _checkInItems.putIfAbsent(cii.uuid, () => cii).update(cii);
    });
    return this;
  }

  toList() => _checkInItems.values.toList();

  toJson() => _checkInItems.values.toList();
}
