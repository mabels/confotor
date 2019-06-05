import 'dart:convert';
import 'dart:io';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/models/lane.dart';
import 'package:confotor/models/ticket-action.dart';
import 'package:confotor/models/ticket.dart';
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

  List<FoundTickets> calculateAmbiguousTickets() {
    print('calculateAmbiguousTickets:start');
    final List<FoundTickets> ret = [];
    _conferences.values.forEach((conf) {
      conf.ticketStore.values.map((i) => i.slug).forEach((slug) {
        final fts = findTickets(slug: slug,
          taction: AmbiguousAction(barcode: slug));
        if (!fts.unambiguous) {
          ret.add(fts);
        }
      });
    });
    print('calculateAmbiguousTickets:done:${ret.length}');
    return ret;
  }

  FoundTickets findTickets({@required String slug,
    @required TicketAction taction, Lane lane}) {
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

          if (ticket.firstName == ref.ticketAndCheckIns.ticket.firstName) {
            if (ticket.lastName == ref.ticketAndCheckIns.ticket.lastName) {
              ret.add(ConferenceTicket(checkInList: conf.checkInList,
                                        ticketAndCheckIns: tac.toTicketAndCheckIns(),
                                        actions: [taction]));
            }
          }
        });
      });
    }
    if (ret.length > _conferences.length) {
      // filter registration_reference
      _removeFrom(ret, _filterTicket(ret, (Ticket t) => t.registrationReference));
    }
    if (ret.length > _conferences.length) {
      // filter email
      _removeFrom(ret, _filterTicket(ret, (Ticket t) => t.email));
    }
    return FoundTickets(conferenceTickets: ret, scan: slug, lane: lane);
  }

  _removeFrom(List<ConferenceTicket> ref, List<ConferenceTicket> toRemove) {
    ref.removeWhere((ct) =>
      toRemove.firstWhere((tct) => ct == tct, orElse: () => null) != null);
  }

  _filterTicket(List<ConferenceTicket> ret, dynamic map(Ticket t)) {
    final ref = map(ret.first.ticketAndCheckIns.ticket);
    final tail = ret.getRange(1, ret.length).toList();
    final found = tail.where((o) => map(o.ticketAndCheckIns.ticket) == ref).toList();
    if (found.isNotEmpty) {
      return tail.where((o) => map(o.ticketAndCheckIns.ticket) != ret).toList();
    }
    return found;
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
