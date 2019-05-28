import 'dart:convert';
import 'dart:io';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:meta/meta.dart';

class LastFoundTicketsStore {
  final ConfotorAppState appState;
  final List<FoundTickets> last = [];
  int maxLen;

  LastFoundTicketsStore({@required ConfotorAppState appState, int maxLen = 20})
      : maxLen = maxLen,
        appState = appState;



  LastFoundTickets toLastFoundTickets() {
    return LastFoundTickets(last: last, maxLen: maxLen);
  }

  LastFoundTicketsStore update(LastFoundTickets lft) {
    maxLen = lft.maxLen;
    lft.last.reversed.forEach((lt) => updateFoundTickets(lt));
    return this;
  }

  LastFoundTicketsStore updateFromConferences(Conferences cfs) {
    cfs.conferences.forEach((cf) {
      last.forEach((ft) {
        final cts = Map.fromEntries(ft.conferenceTickets
                    .where((ct) => ct.checkInList.url == cf.checkInList.url)
                    .map((ct) => MapEntry(ct.ticketAndCheckIns.ticket.id, ct)));
        cf.ticketAndCheckInsList.forEach((tac) {
          if (cts.containsKey(tac.ticket.id)) {
            // tac.state;
            cts[tac.ticket.id].ticketAndCheckIns.updateCheckInItems(tac.checkInItems);
          }
        });
      });
    });
  }

  LastFoundTicketsStore updateFoundTickets(FoundTickets oth) {
    final idx = last.indexWhere((t) => t.slug == oth.slug);
    if (idx >= 0) {
      last.removeAt(idx);
    }
    this.last.insert(0, oth);
    for (var i = maxLen; i < last.length; i++) {
      last.removeLast();
    }
    return this;
  }

  Future<File> get fileName async {
    final path = await appState.getLocalPath();
    return new File('$path/last-ticket-store.json');
  }

  _doCheckoutList(ConferenceTicket ct, List<CheckInItem> toDeletes) {
    if (toDeletes.isEmpty) {
      // request checklist
      appState.bus.add(RequestUpdateConference(checkInList: ct.checkInList));
      return;
    }
    final toDelete = toDeletes.removeLast();
    final action = CheckOutTransactionTicketAction(
        step: CheckInOutTransactionTicketActionStep.Started,
        uuid: toDelete.uuid);
    ct.actions.add(action);
    appState.bus.add(this.toLastFoundTickets());
    action.run(url: ct.checkInList.checkOutUrl(toDelete.uuid)).then((_) {
      appState.bus.add(this.toLastFoundTickets());
      _doCheckoutList(ct, toDeletes);
    }).catchError((e) {
      print('_doCheckoutList:$e');
      appState.bus.add(this.toLastFoundTickets());
    });
  }

  doCheckOut(ConferenceTicket conferenceTicket) {
    last.firstWhere((ft) {
      final found = ft.conferenceTickets.firstWhere(
          (ct) =>
              ct.checkInList.url == conferenceTicket.checkInList.url &&
              ct.ticketAndCheckIns.ticket.slug ==
                  conferenceTicket.ticketAndCheckIns.ticket.slug,
          orElse: () => null);
      if (found != null) {
        final ignore = found.actions.firstWhere(
            (a) =>
                a is CheckOutTransactionTicketAction &&
                !(a.step == CheckInOutTransactionTicketActionStep.Completed ||
                  a.step == CheckInOutTransactionTicketActionStep.Error),
            orElse: () => null);
        if (ignore != null) {
          print('ignore doCheckOut');
          return found != null;
        }
        final toDelete = found.ticketAndCheckIns.checkInItems
            .where((i) => i.deleted_at == null)
            .toList();
        if (toDelete.isNotEmpty) {
          _doCheckoutList(found, toDelete);
        }
      }
      return found != null;
    }, orElse: () => null);
  }

  doCheckIn(ConferenceTicket conferenceTicket) {
    last.firstWhere((ft) {
      final found = ft.conferenceTickets.firstWhere(
          (ct) =>
              ct.checkInList.url == conferenceTicket.checkInList.url &&
              ct.ticketAndCheckIns.ticket.slug ==
                  conferenceTicket.ticketAndCheckIns.ticket.slug,
          orElse: () => null);
      if (found != null) {
        final ignore = found.actions.firstWhere(
            (a) =>
                a is CheckInTransactionTicketAction &&
                !(a.step == CheckInOutTransactionTicketActionStep.Completed ||
                    a.step == CheckInOutTransactionTicketActionStep.Error),
            orElse: () => null);
        if (ignore != null) {
          print('ignore doCheckIn');
          return found != null;
        }
        final action = CheckInTransactionTicketAction(
            step: CheckInOutTransactionTicketActionStep.Started);
        found.actions.add(action);
        appState.bus.add(this.toLastFoundTickets());
        action
            .run(
                url: found.checkInList.checkInUrl(),
                ticketId: found.ticketAndCheckIns.ticket.id)
            .then((_) {
          appState.bus.add(this.toLastFoundTickets());
          appState.bus.add(RequestUpdateConference(checkInList: found.checkInList));
        }).catchError((e) {
          print('doCheckIn:$e');
          appState.bus.add(this.toLastFoundTickets());
        });
      }
      return found != null;
    }, orElse: () => null);
  }

  write() {
    fileName.then((file) {
      String str;
      try {
        str = json.encode({"lastFoundTickets": toLastFoundTickets()});
      } on dynamic catch (e) {
        print('JsonEncode:Error:$e');
        return this;
      }
      file.writeAsString(str).then((file) {
        print('lastfoundtickets:write:$file:$str');
      }).catchError((e) => print('lastfoundtickets:Error:$e'));
    });
  }

  void read() {
    /*
    .then((confs) {
      confs.values.forEach((conf) => this.appState.bus.add(RequestUpdateConference(checkInListItem: conf.checkInListItem)));
    }).catchError((e) {
    });
    */
    fileName.then((file) {
      file.readAsString().then((str) {
        try {
          print('read:$file:$str');
          appState.bus
              .add(JsonObject(json: json.decode(str), fileName: file.path));
        } catch (e) {
          appState.bus
              .add(JsonObjectError(error: e, str: str, fileName: file.path));
        }
      }).catchError((e) {
        appState.bus.add(new FileError(error: e, fileName: file.path));
      });
    }).catchError((e) {
      appState.bus.add(new FileError(error: e));
    });
  }
}
