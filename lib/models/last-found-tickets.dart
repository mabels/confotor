import 'dart:convert';
import 'dart:io';

import 'package:confotor/models/found-tickets.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';

part 'last-found-tickets.g.dart';

class LastFoundTickets extends LastFoundTicketsBase with _$LastFoundTickets {
}

abstract class LastFoundTicketsBase with Store {
  final ConfotorAppState _appState;
  final ObserverList<FoundTickets> last = ObserverList();
  @observable
  int maxLen;

  LastFoundTicketsBase({@required ConfotorAppState appState, int maxLen = 20})
      : maxLen = maxLen,
        _appState = appState;

  // LastFoundTickets toLastFoundTickets() {
  //   return LastFoundTickets(last: last, maxLen: maxLen);
  // }

  // void reset() {
  //   last.clear();
  // }

  // LastFoundTicketsStore update(LastFoundTickets lft) {
  //   maxLen = lft.maxLen;
  //   lft.values.reversed.forEach((lt) => updateFoundTickets(lt));
  //   return this;
  // }

  // LastFoundTicketsStore updateFromConferences(Conferences cfs) {
  //   cfs.conferences.forEach((cf) {
  //     last.forEach((ft) {
  //       final cts = Map.fromEntries(ft.conferenceTickets
  //                   .where((ct) => ct.checkInList.url == cf.checkInList.url)
  //                   .map((ct) => MapEntry(ct.ticketAndCheckIns.ticket.id, ct)));
  //       cf.ticketAndCheckInsList.forEach((tac) {
  //         if (cts.containsKey(tac.ticket.id)) {
  //           // tac.state;
  //           cts[tac.ticket.id].ticketAndCheckIns.updateCheckInItems(tac.checkInItems);
  //         }
  //       });
  //     });
  //   });
  //   return this;
  // }

  Future<File> get _fileName async {
    final path = await _appState.getLocalPath();
    return new File('$path/last-ticket-store.json');
  }

  // _doCheckoutList(ConferenceTicket ct, List<CheckInItem> toDeletes) {
  //   if (toDeletes.isEmpty) {
  //     // request checklist
  //     _appState.bus.add(RequestUpdateConference(checkInList: ct.checkInList));
  //     return;
  //   }
  //   final toDelete = toDeletes.removeLast();
  //   final action = CheckOutTransactionTicketAction(
  //       step: CheckInOutTransactionTicketActionStep.Started,
  //       uuid: toDelete.uuid);
  //   ct.actions.add(action);
  //   _appState.bus.add(this.toLastFoundTickets());
  //   action.run(url: ct.checkInList.checkOutUrl(toDelete.uuid)).then((_) {
  //     _appState.bus.add(this.toLastFoundTickets());
  //     _doCheckoutList(ct, toDeletes);
  //   }).catchError((e) {
  //     print('_doCheckoutList:$e');
  //     _appState.bus.add(this.toLastFoundTickets());
  //   });
  // }

  // doCheckOut(ConferenceTicket conferenceTicket) {
  //   last.firstWhere((ft) {
  //     final found = ft.conferenceTickets.firstWhere(
  //         (ct) =>
  //             ct.checkInList.url == conferenceTicket.checkInList.url &&
  //             ct.ticketAndCheckIns.ticket.slug ==
  //                 conferenceTicket.ticketAndCheckIns.ticket.slug,
  //         orElse: () => null);
  //     if (found != null) {
  //       final ignore = found.actions.firstWhere(
  //           (a) =>
  //               a is CheckOutTransactionTicketAction &&
  //               !(a.step == CheckInOutTransactionTicketActionStep.Completed ||
  //                 a.step == CheckInOutTransactionTicketActionStep.Error),
  //           orElse: () => null);
  //       if (ignore != null) {
  //         print('ignore doCheckOut');
  //         return found != null;
  //       }
  //       final toDelete = found.ticketAndCheckIns.checkInItems
  //           .where((i) => i.deletedAt == null)
  //           .toList();
  //       if (toDelete.isNotEmpty) {
  //         _doCheckoutList(found, toDelete);
  //       }
  //     }
  //     return found != null;
  //   }, orElse: () => null);
  // }

  // doCheckIn(ConferenceTicket conferenceTicket) {
  //   last.firstWhere((ft) {
  //     final found = ft.conferenceTickets.firstWhere(
  //         (ct) =>
  //             ct.checkInList.url == conferenceTicket.checkInList.url &&
  //             ct.ticketAndCheckIns.ticket.slug ==
  //                 conferenceTicket.ticketAndCheckIns.ticket.slug,
  //         orElse: () => null);
  //     if (found != null) {
  //       final ignore = found.actions.firstWhere(
  //           (a) =>
  //               a is CheckInTransactionTicketAction &&
  //               !(a.step == CheckInOutTransactionTicketActionStep.Completed ||
  //                   a.step == CheckInOutTransactionTicketActionStep.Error),
  //           orElse: () => null);
  //       if (ignore != null) {
  //         print('ignore doCheckIn');
  //         return found != null;
  //       }
  //       final action = CheckInTransactionTicketAction(
  //           step: CheckInOutTransactionTicketActionStep.Started);
  //       found.actions.add(action);
  //       _appState.bus.add(this.toLastFoundTickets());
  //       action
  //           .run(
  //               url: found.checkInList.checkInUrl(),
  //               ticketId: found.ticketAndCheckIns.ticket.id)
  //           .then((_) {
  //         _appState.bus.add(this.toLastFoundTickets());
  //         _appState.bus.add(RequestUpdateConference(checkInList: found.checkInList));
  //       }).catchError((e) {
  //         print('doCheckIn:$e');
  //         _appState.bus.add(this.toLastFoundTickets());
  //       });
  //     }
  //     return found != null;
  //   }, orElse: () => null);
  // }

  Map<String, dynamic> toJson() => {
    "last": last,
    "maxLen": maxLen
  };

  write() {
    _fileName.then((file) {
      String str;
      try {
        str = json.encode({"lastFoundTickets": this});
      } on dynamic catch (e) {
        print('JsonEncode:Error:$e');
        return this;
      }
      file.writeAsString(str).then((file) {
        print('lastfoundtickets:write:$file:$str');
      }).catchError((e) => print('lastfoundtickets:Error:$e'));
    });
  }

  static LastFoundTickets read() {
    _fileName.then((file) {
      file.readAsString().then((str) {
        try {
          print('read:$file:$str');
          _appState.bus
              .add(JsonObject(json: json.decode(str), fileName: file.path));
        } catch (e) {
          _appState.bus
              .add(JsonObjectError(error: e, str: str, fileName: file.path));
        }
      }).catchError((e) {
        _appState.bus.add(new FileError(error: e, fileName: file.path));
      });
    }).catchError((e) {
      _appState.bus.add(new FileError(error: e));
    });
  }
}
