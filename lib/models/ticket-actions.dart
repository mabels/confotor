import 'package:flutter/foundation.dart';

import 'ticket-action.dart';

class TicketActions {
  final List<TicketAction> _actions;

  static _updateTicketActions(Iterable<TicketAction> src, List<TicketAction> dst) {
    dst.addAll(src);
    return dst;
  }

  static TicketActions fromJson(List<dynamic> my) {
    return TicketActions(my.map((i) => TicketAction.fromJson(my)));
  }

  TicketActions(Iterable<TicketAction> actions) : _actions = _updateTicketActions(actions, []);

  @override
  bool operator ==(o) {
    return o is TicketActions && listEquals(o._actions, _actions);
  }

  List<dynamic> toJson() => _actions;

}
