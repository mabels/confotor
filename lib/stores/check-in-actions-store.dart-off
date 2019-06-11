
import 'package:confotor/models/check-in-action.dart';

class CheckInActionsStore {
  final Map<String, CheckInAction> _checkInActions = Map();

  update(List<CheckInAction> oth) {
    oth.forEach((jsonItem) {
      final item = CheckInAction.fromJson(jsonItem);
      _checkInActions.putIfAbsent(item.id, () => item).update(item);
    });
    return this;
  }


  // updateFromJson(dynamic json) {
  //   List<dynamic> checkInItems = json;
  //   if (checkInItems == null) {
  //     checkInItems = [];
  //   }
  //   checkInItems.forEach((jsonItem) {
  //     final item = CheckInAction.fromJson(jsonItem);
  //     _checkInActions.putIfAbsent(item.id, () => item).update(item);
  //   });
  //   return this;
  // }

  toJson() => _checkInActions.values.toList();
  toList() => _checkInActions.values.toList();

}