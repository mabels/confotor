
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'conference-ticket.dart';
import 'lane.dart';

class FoundTickets extends ConfotorMsg {
  final List<ConferenceTicket> conferenceTickets;
  final Lane lane;
  final String scan;

  FoundTickets({
    @required String scan,
    @required Lane lane,
    @required List<ConferenceTicket> conferenceTickets
  }):
    conferenceTickets = conferenceTickets,
    lane = lane,
    scan = scan;

  @override
  bool operator ==(o) {
    return o is FoundTickets &&
      listEquals(conferenceTickets, o.conferenceTickets) &&
      lane == o.lane &&
      scan == scan;
  }

  List<String> get slugs {
    return conferenceTickets.map((t) => t.ticketAndCheckIns.ticket.slug).toList();
  }

  bool get isInTicketLane {
    if (lane == null) {
      return true;
    }
    return lane.isNameInLane(conferenceTickets.first.ticketAndCheckIns.ticket.firstName);
  }

  bool get unambiguous {
    return conferenceTickets.length == Set.from(conferenceTickets.map((i) => i.checkInList.url)).length;
  }

  bool containsSlug(FoundTickets oth) {
    final mySlugs = Set.from(this.slugs);
    return oth.conferenceTickets.firstWhere((o) => mySlugs.contains(o.ticketAndCheckIns.ticket.slug),
      orElse: () => null) != null;
  }

  get hasFound => conferenceTickets.isNotEmpty;

  get name {
    return hasFound ? "${conferenceTickets.first.ticketAndCheckIns.ticket.firstName} ${conferenceTickets.first.ticketAndCheckIns.ticket.lastName}" : "John Doe";
  }

  static FoundTickets fromJson(dynamic json) {
    final List<ConferenceTicket> conferenceTickets = [];
    if (json['conferenceTickets'] is List) {
      final List<dynamic> cts = json['conferenceTickets'];
      cts.forEach((ct) => conferenceTickets.add(ConferenceTicket.fromJson(ct)));
    }
    return FoundTickets(conferenceTickets: conferenceTickets, scan: json['scan'], lane: Lane.fromJson(json['lane']));
  }

  Map<String, dynamic> toJson() => {
    "conferenceTickets": conferenceTickets,
    "scan": scan,
    "lane": lane
  };

}

class LastFoundTickets extends ConfotorMsg {
  final List<FoundTickets> _last = [];
  int _maxLen;

  LastFoundTickets({
    List<FoundTickets> last,
    int maxLen = 20
    }) : _maxLen = maxLen {
      if (last is List) {
        last.reversed.forEach((fts) => append(fts));
      }
    }

  LastFoundTickets clone() {
    return LastFoundTickets(last: _last, maxLen: _maxLen);
  }

  Iterable<FoundTickets> get values => _last;

  static LastFoundTickets fromJson(dynamic json) {
    final List<FoundTickets> last = [];
    if (json['last'] is List) {
      final List<dynamic> lst = json['last'];
      lst.forEach((ft) => last.add(FoundTickets.fromJson(ft)));
    }
    int maxLen = 20;
    if (json['maxLen'] is int) {
      maxLen = json['maxLen'];
    }
    return LastFoundTickets(last: last, maxLen: maxLen);
  }

  FoundTickets get first => _last.first;
  FoundTickets get last => _last.last;

  int get length => _last.length;

  int get maxLen => _maxLen;

  set maxLen(int v) {
    _maxLen = v;
    // toList need we modify last in append
    this._last.toList().reversed.forEach((fts) => append(fts));
  }

  append(FoundTickets oth) {
    final idx = _last.indexWhere((t) => t.containsSlug(oth));
    if (idx >= 0) {
      _last.removeAt(idx);
    }
    this._last.insert(0, oth);
    for (var i = maxLen, olen = _last.length; i < olen; i++) {
      _last.removeLast();
    }
    return this;
  }

  Map<String, dynamic> toJson() => {
    "last": _last,
    "maxLen": maxLen
  };

}
