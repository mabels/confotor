import 'dart:convert';
import 'dart:io';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:meta/meta.dart';

import 'conference-store.dart';

class ConferencesStore {
  final ConfotorAppState appState;

  final Map<String, ConferenceStore> _conferences = Map();

  ConferencesStore({@required appState}) : appState = appState;

  Conference updateConference(RequestUpdateConference ruc) {
    return _conferences
        .putIfAbsent(ruc.checkInListItem.url, () => ConferenceStore(appState: appState))
        .update(ruc);
  }

  List<ConferenceStore> get values => _conferences.values;

  remove(ConferenceKey key) {
    return _conferences.remove(key.url);
  }

  FoundTickets findTickets(String slug) {
    final List<TicketAndCheckIns> ret = [];
    final inConf = _conferences.values.firstWhere((item) {
      // print('findTickets:${item.url}:${item.ticketsCount}:$slug');
      final found = item.ticketStore.firstWhere((tac) {
        // print('findTickets:${item.url}:${item.ticketsCount}:$slug:${ticket.slug}');
        return tac.ticket.slug == slug;
      });
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
    // return FoundTickets(tickets: ret);
  }

  Future<File> get _localFile async {
    final path = await appState.getLocalPath();
    print('_localFile:$path');
    return new File('$path/check-in-lists.json');
  }

  Future<ConferencesStore> writeConference() async {
    final file = await _localFile;
    String str;
    try {
      str = json.encode(_conferences);
    } on dynamic catch (e) {
      print('JsonEncode:Error:$e');
      return this;
    }
    try {
      await file.writeAsString(str);
    } on dynamic catch (e) {
      print('WriteLists:Error:$e');
    }
    return this;
  }

  void readConferences() {
    /*
    .then((confs) {
      confs.values.forEach((conf) => this.appState.bus.add(RequestUpdateConference(checkInListItem: conf.checkInListItem)));
    }).catchError((e) {
    });
    */
    _localFile.then((file) {
      file.readAsString().then((str) {
        try {
          final List<dynamic> contents = json.decode(str);
          contents.forEach((json) {
            appState.bus.add(RequestUpdateConference(
                checkInListItem:
                    CheckInListItem.fromJson(json['checkInListItem']),
                ticketAndCheckIns: (json['ticketAndCheckIns'] as List<dynamic>)
                    .map((j) => TicketAndCheckIns.fromJson(j))));
          });
        } catch (e) {
          appState.bus.add(ConferencesError(error: e));
        }
      }).catchError((e) {
        appState.bus.add(new ConferencesError(error: e));
      });
    }).catchError((e) {
      appState.bus.add(new ConferencesError(error: e));
    });
  }
}
