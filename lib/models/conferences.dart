import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/msgs/msgs.dart';

class Conferences {
  final Map<String, Conference> _conferences = Map();

  toJson() => _conferences.values.toList();

  updateConferenceFromJson(dynamic json) {
    _conferences
        .putIfAbsent(json['url'], () => Conference.fromJson(json))
        .updateFromJson(json);
  }

  remove(String url) {
    return _conferences.remove(url);
  }

  FoundTickets findTickets(String slug) {
    final List<TicketAndCheckIns> ret = [];
    final inConf = _conferences.values.firstWhere((item) {
      // print('findTickets:${item.url}:${item.ticketsCount}:$slug');
      final found = item.ticketStore.values.firstWhere((tac) {
        // print('findTickets:${item.url}:${item.ticketsCount}:$slug:${ticket.slug}');
        return tac.ticket.slug == slug;
      }, orElse: () => null);
      // print('findTickets:NEXT:${item.url}:${item.ticketsCount}:$slug:$found');
      if (found != null) {
        // print("findTickets:Found:${found.slug}:${slug}");
        ret.add(found);
      }
      return found != null;
    }, orElse: () => null);
    if (inConf != null) {
      final ref = ret.first;
      _conferences.values.where((c) => c.url != inConf.url).forEach((conf) {
        conf.ticketStore.values.forEach((tac) {
          final ticket = tac.ticket;
          if (ticket.registration_reference ==
              ref.ticket.registration_reference) {
            ret.add(tac);
            return;
          }
          if (ticket.email == ref.ticket.email) {
            if (ticket.company_name == ref.ticket.company_name) {
              if (ticket.first_name == ref.ticket.first_name) {
                if (ticket.last_name == ref.ticket.last_name) {
                  ret.add(tac);
                }
              }
            }
            return;
          }
        });
      });
    }
    return FoundTickets(tickets: ret);
  }
}
