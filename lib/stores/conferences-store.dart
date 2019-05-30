import 'dart:convert';
import 'dart:io';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:meta/meta.dart';

import 'conference-store.dart';

class ConferencesStore {
  final ConfotorAppState appState;

  final Map<String, ConferenceStore> _conferences = Map();

  ConferencesStore({@required appState}) : appState = appState;

  ConferenceStore updateConference(RequestUpdateConference ruc) {
    return _conferences
        .putIfAbsent(ruc.checkInList.url, () => ConferenceStore(appState: appState, checkInList: ruc.checkInList))
        .update(ruc);
  }

  ConferenceStore updateCheckInItemPage(CheckInItemPageMsg ciim) {
    return _conferences
        .putIfAbsent(ciim.checkInList.url, () => ConferenceStore(appState: appState, checkInList: ciim.checkInList))
        .updateCheckInItems(ciim.items);
  }

  //   ConferenceStore updateCheckInActionPage(CheckInActionPageMsg ciam) {
  //   return _conferences
  //       .putIfAbsent(ciam.checkInList.url, () => ConferenceStore(appState: appState, checkInList: ciam.checkInList))
  //       .updateCheckInActions(ciam.items);
  // }

  ConferenceStore updateTicketPage(TicketPageMsg tpm) {
    return _conferences
        .putIfAbsent(tpm.checkInList.url, () => ConferenceStore(appState: appState, checkInList: tpm.checkInList))
        .updateTickets(tpm.items);
  }

  List<ConferenceStore> get values => _conferences.values;

  // Conferences toConferences() {
  //   return Conferences(conferences: _conferences.values.map((i) => Conference(
  //     checkInList: i.checkInList,
  //     ticketAndCheckInsList: i.ticketStore.values.map((ts) => ts.toTicketAndCheckIns()).toList()
  //   )).toList());
  // }

  remove(ConferenceKey key) {
    return _conferences.remove(key.url);
  }

  FoundTickets findTickets(String slug, TicketAction taction) {
    final List<ConferenceTicket> ret = [];
    final inConf = _conferences.values.firstWhere((conf) {
      // print('findTickets:${item.url}:${item.ticketsCount}:$slug');
      final found = conf.ticketStore.firstWhere((tac) {
        // print('findTickets:${item.url}:${item.ticketsCount}:$slug:${ticket.slug}');
        return tac.ticket.slug == slug;
      });
      // print('findTickets:NEXT:${item.url}:${item.ticketsCount}:$slug:$found');
      if (found != null) {
        // print("findTickets:Found:${found.slug}:${slug}");
        ret.add(ConferenceTicket(checkInList: conf.checkInList,
                                 ticketAndCheckIns: found.toTicketAndCheckIns(),
                                 actions: [taction]));
      }
      return found != null;
    }, orElse: () => null);
    if (inConf != null) {
      final ConferenceTicket ref = ret.first;
      _conferences.values.where((c) => c.url != inConf.url).forEach((conf) {
        conf.ticketStore.values.forEach((tac) {
          final ticket = tac.ticket;
          if (ticket.registration_reference ==
              ref.ticketAndCheckIns.ticket.registration_reference) {
            ret.add(ConferenceTicket(checkInList: conf.checkInList,
                                     ticketAndCheckIns: tac.toTicketAndCheckIns(),
                                     actions: [taction]));
            return;
          }
          if (ticket.email == ref.ticketAndCheckIns.ticket.email) {
            if (ticket.company_name == ref.ticketAndCheckIns.ticket.company_name) {
              if (ticket.first_name == ref.ticketAndCheckIns.ticket.first_name) {
                if (ticket.last_name == ref.ticketAndCheckIns.ticket.last_name) {
                  ret.add(ConferenceTicket(checkInList: conf.checkInList,
                                           ticketAndCheckIns: tac.toTicketAndCheckIns(),
                                           actions: [taction]));
                }
              }
            }
            return;
          }
        });
      });
    }
    return FoundTickets(conferenceTickets: ret, scan: slug);
  }

  Future<File> get fileName async {
    final path = await appState.getLocalPath();
    // print('_localFile:$path');
    return new File('$path/conferences.json');
  }

  Conferences toConferences() {
    return Conferences(conferences: _conferences.values.map((i) => i.toConference()).toList());
    // return Conferences(conferences: []);
  }

  Future<ConferencesStore> writeConference() async {
    final file = await fileName;
    String str;
    // print('writeConference');
    try {
      str = json.encode({
        "conferences": toConferences()
      });
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
    fileName.then((file) {
      file.readAsString().then((str) {
        try {
          appState.bus.add(JsonObject(json: json.decode(str), fileName: file.path));
        } catch (e) {
          appState.bus.add(JsonObjectError(error: e, str: str, fileName: file.path));
        }
      }).catchError((e) {
        appState.bus.add(new FileError(error: e, fileName: file.path));
      });
    }).catchError((e) {
      appState.bus.add(new FileError(error: e));
    });
  }
}
