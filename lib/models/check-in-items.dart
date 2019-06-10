import 'package:confotor/models/check-in-item.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class CheckInItems {
  final int ticketId;
  final List<CheckInItem> _checkInItems = [];

  static _updateCheckInItem(
      CheckInItem cii, List<CheckInItem> target, int ticketId) {
    if (cii == null) {
      return target;
    }
    if (cii.ticketId != ticketId) {
      throw Exception('CheckInItem does not match ticketId');
    }
    final lookup =
        Map.fromEntries(target.map((cii) => MapEntry(cii.uuid, cii)));
    lookup.putIfAbsent(cii.uuid, () {
      target.add(cii);
      return cii;
    }).update(cii);
    target.sort((a, b) => a.uuid.compareTo(b.uuid));
    return target;
  }

  static CheckInItems fromJson(Map<String, dynamic> my) {
    List<dynamic> lst = my['checkInItems'];
    return CheckInItems(
        ticketId: my['ticketId'],
        checkInItems: lst.map((i) => CheckInItem.fromJson(i)));
  }

  CheckInItems(
      {@required int ticketId, @required Iterable<CheckInItem> checkInItems})
      : ticketId = ticketId {
    if (!(ticketId is int)) {
      throw Exception('TicketID must be an int');
    }
    if (checkInItems is Iterable) {
      checkInItems.forEach((cii) => _updateCheckInItem(cii, _checkInItems, ticketId));
    }
  }

  @override
  bool operator ==(o) {
    return o is CheckInItems &&
        ticketId == o.ticketId &&
        listEquals(_checkInItems, o.checkInItems);
  }

  Iterable<CheckInItem> get checkInItems => _checkInItems;

  int get length => _checkInItems.length;

  CheckInItem get first => _checkInItems.first;
  CheckInItem get last => _checkInItems.last;

  CheckInItem firstWhere(bool cb(CheckInItem i), {CheckInItem orElse()}) =>
      _checkInItems.firstWhere(cb, orElse: orElse);

  Iterable<CheckInItem> get iterable => _checkInItems;

  void updateCheckInItem(CheckInItem src) {
    _updateCheckInItem(src, _checkInItems, ticketId);
  }

  CheckInItem get lastCheckedIn {
    final toSort = _checkInItems.where((cii) => cii.deletedAt == null).toList();
    toSort.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return toSort.last;
  }

  Map<String, dynamic> toJson() =>
      {"ticketId": ticketId, "checkInItems": _checkInItems};
}
