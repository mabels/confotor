
import 'check-in-action.dart';

class CheckInActions {
  final Map<String, CheckInAction> _checkInActions = Map();

  updateFromJson(dynamic json) {
    List<dynamic> checkInItems = json;
    if (checkInItems == null) {
      checkInItems = [];
    }
    checkInItems.forEach((jsonItem) {
      final item = CheckInAction.fromJson(jsonItem);
      _checkInActions.putIfAbsent(item.id, () => item).update(item);
    });
    return this;
  }

  toJson() => _checkInActions.values.toList();

}