
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:meta/meta.dart';

class FoundTickets extends ConfotorMsg {
  final List<ConferenceTicket> conferenceTickets;
  final String scan;

  FoundTickets({
    @required String scan,
    @required List<ConferenceTicket> conferenceTickets
  }): 
    conferenceTickets = conferenceTickets,
    scan = scan;

  List<String> get slugs {
    return conferenceTickets.map((t) => t.ticketAndCheckIns.ticket.slug).toList();
  }

  bool get autoCheckinable {
    return conferenceTickets.length == Set.from(conferenceTickets.map((i) => i.checkInList.url)).length;
  }

  bool containsSlug(FoundTickets oth) {
    final mySlugs = Set.from(this.slugs);
    return oth.conferenceTickets.firstWhere((o) => mySlugs.contains(o.ticketAndCheckIns.ticket.slug),
      orElse: () => null) != null;
  }

  get hasFound => conferenceTickets.isNotEmpty;

  get name {
    return hasFound ? "${conferenceTickets.first.ticketAndCheckIns.ticket.first_name} ${conferenceTickets.first.ticketAndCheckIns.ticket.last_name}" : "John Doe";
  }

  static FoundTickets fromJson(dynamic json) {
    final List<ConferenceTicket> conferenceTickets = [];
    if (json['conferenceTickets'] is List) {
      final List<dynamic> cts = json['conferenceTickets'];
      cts.forEach((ct) => conferenceTickets.add(ConferenceTicket.fromJson(ct)));
    }
    return FoundTickets(conferenceTickets: conferenceTickets, scan: json['scan']);
  }

  Map<String, dynamic> toJson() => {
    "conferenceTickets": conferenceTickets,
    "scan": scan
  };

}

class LastFoundTickets extends ConfotorMsg {
  final List<FoundTickets> last;
  final int maxLen;

  LastFoundTickets({
    @required List<FoundTickets> last,
    int maxLen = 20
    }): last = List.from(last), maxLen = maxLen;

  LastFoundTickets clone() {
    return LastFoundTickets(last: last, maxLen: maxLen);
  }

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


  Map<String, dynamic> toJson() => {
    "last": last,
    "maxLen": maxLen
  };

}
