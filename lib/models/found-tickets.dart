
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:meta/meta.dart';

class FoundTickets extends ConfotorMsg {
  final List<ConferenceTicket> conferenceTickets;
  FoundTickets({@required List<ConferenceTicket> conferenceTickets}): 
    conferenceTickets = conferenceTickets;

  get hasFound {
    return conferenceTickets.isNotEmpty;
  }
  get slug {
    return hasFound ? conferenceTickets.first.ticketAndCheckIns.ticket.slug : "Not Found";
  }
  get name {
    return hasFound ? "${conferenceTickets.first.ticketAndCheckIns.ticket.first_name} ${conferenceTickets.first.ticketAndCheckIns.ticket.last_name}" : "John Doe";
  }

  static FoundTickets fromJson(dynamic json) {
    final conferenceTickets = [];
    if (json['conferenceTickets'] is List) {
      final List<dynamic> cts = json['conferenceTickets'];
      cts.forEach((ct) => conferenceTickets.add(ConferenceTicket.fromJson(ct)));
    }
    return FoundTickets(conferenceTickets: conferenceTickets);
  }

  Map<String, dynamic> toJson() => {
    "conferenceTickets": conferenceTickets
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
