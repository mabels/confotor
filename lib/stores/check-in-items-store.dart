
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/ticket-and-checkins.dart';

class CheckInItemsStore {
  final Map<String /*uuid*/, CheckInItem> _checkInItems = Map();

  get length {
    return _checkInItems.length;
  }

  TicketAndCheckInsState get state {
    final open = _checkInItems.values.firstWhere((i) => i.deleted_at == null, orElse: () => null);
    if (open != null) {
      return TicketAndCheckInsState.Used;
    }
    return TicketAndCheckInsState.Issueable;
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
