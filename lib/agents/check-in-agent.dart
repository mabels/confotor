import 'dart:async';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CheckInObserver {
  final ConfotorAppState appState;
  final CheckInList checkInList;
  Timer timer;
  // int count = 0;
  DateTime since;
  DateTime nextSince;

  CheckInObserver(
      {@required ConfotorAppState appState, @required CheckInList checkInList})
      : checkInList = checkInList,
        appState = appState;

  getPage(int page, String transaction) {
    final url = checkInList.checkInUrl(
        since: since == null ? 0 : since.millisecondsSinceEpoch / 1000,
        page: page);
    print('getPage:$url:$page:since:${since == null ? 0 : since.millisecondsSinceEpoch / 1000}');
    http.get(url).then((res) {
      print('getPage:$url:$page:pre');
      List<dynamic> json = convert.jsonDecode(res.body);
      print('getPage:$url:$page:${json.length}');
      final items = json.map((i) {
        final item = CheckInItem.fromJson(i);
        if (nextSince == null) {
          nextSince = item.maxDate;
        } else {
          nextSince =
              item.maxDate.compareTo(nextSince) > 0 ? item.maxDate : nextSince;
        }
        return item;
      });
      print('getPage:$url:$page:pos');
      appState.bus.add(CheckInItemPageMsg(
        checkInList: checkInList,
        transaction: transaction,
        items: items.toList(),
        page: page,
        completed: items.isEmpty,
      ));
      print('getPage:$url:$page:pos:1');
      if (items.isNotEmpty) {
        print('getPage:$url:$page:pos:2');
        getPage(page + 1, transaction);
      } else {
        print('getPage:$url:$page:pos:3:$nextSince');
        since = nextSince;
        // nextSince = null;
        start();
      }
    }).catchError((err) {
      appState.bus.add(CheckInObserverError(
          error: err, conference: checkInList, transaction: transaction));
    });
  }

  CheckInObserver start({int seconds = 5}) {
    stop();
    timer = new Timer(Duration(seconds: seconds), () {
      getPage(1, appState.uuid.v4()); // paged api triggered by page 1
    });
    return this;
  }

  stop() {
    if (timer != null) {
      timer.cancel();
    }
  }
}

// class CheckedTicket extends ConfotorMsg {
//   final FoundTicket foundTicket;
//   final http.Response res;
//   CheckedTicket({FoundTicket foundTicket, http.Response res}):
//     foundTicket = foundTicket,
//     res = res;
// }

// class CheckedTicketError extends ConfotorMsg implements ConfotorErrorMsg {
//   final dynamic error;
//   CheckedTicketError({FoundTicket foundTicket, http.Response res, dynamic error}):
//     error = error;
// }

// class CheckedInTicket extends CheckedTicket {
//   final CheckedInResponse checkedIn;

//   CheckedInTicket({FoundTicket foundTicket, http.Response res}):
//     checkedIn = CheckedInResponse.create(res),
//     super(foundTicket: foundTicket, res: res);
// }

// class CheckedOutTicket extends CheckedTicket {
//   CheckedOutTicket({FoundTicket foundTicket, http.Response res}):
//     super(foundTicket: foundTicket, res: res);
// }

// class RequestCheckOutTicket extends ConfotorMsg {
//   final FoundTicket foundTicket;
//   RequestCheckOutTicket({FoundTicket foundTicket}):
//     foundTicket = foundTicket;
// }

class CheckInAgent {
  final ConfotorAppState appState;
  final Map<String /* url */, CheckInObserver> observers = new Map();
  StreamSubscription subscription;

  CheckInAgent({@required ConfotorAppState appState}) : appState = appState;

  stop() {
    subscription.cancel();
  }

  CheckInAgent start() {
    subscription = this.appState.bus.listen((msg) {
      if (msg is AppLifecycleMsg) {
        switch (msg.state) {
          // case AppLifecycleState.inactive:
          case AppLifecycleState.paused:
            observers.values.forEach((o) {
              o.stop();
            });
            break;
          case AppLifecycleState.suspending:
          case AppLifecycleState.resumed:
            observers.values.forEach((o) {
              o.start(seconds: 0);
            });
            break;
          case AppLifecycleState.inactive:
            break;
        }
      }
      if (msg is UpdatedConference) {
        print('CheckInAgent:UpdatedConference:${msg.checkInListItem.url}');
        if (!observers.containsKey(msg.checkInListItem.url)) {
          print('CheckInAgent:UpdatedConference:${msg.checkInListItem.url}:create');
          observers[msg.checkInListItem.url] = CheckInObserver(
              appState: appState, checkInList: msg.checkInListItem);
          observers[msg.checkInListItem.url].start(seconds: 0);
        }
      }

      if (msg is ConferenceRemoved) {
        if (observers.containsKey(msg.checkInItemMsg.url)) {
          observers[msg.checkInItemMsg.url].stop();
          observers.remove(msg.checkInItemMsg.url);
        }
      }

      // if (msg is RequestCheckOutTicket) {
      //   final FoundTicket ft = msg.foundTicket;
      //   if (ft.checkedIns.last is CheckedInTicket) {
      //     http.delete(ft.checkInListItem.checkOutUrl(ft.checkedIns.last.checkedIn.uuid)).then((res) {
      //         this.appState.bus.add(CheckedOutTicket(foundTicket: ft, res: res));
      //       }).catchError((e) {
      //         this.appState.bus.add(CheckedTicketError(foundTicket: ft, error: e));
      //       });
      //   }
      // }
      // if (msg is CheckedInTicket) {
      //   final CheckedInTicket cit = msg;
      //   if (!observers.containsKey(cit.foundTicket.checkInListItem.url)) {
      //     observers[cit.foundTicket.checkInListItem.url].start(seconds: 0);
      //   }
      // }
      // if (msg is ConferenceKeysMsg) {
      //   final ConferenceKeysMsg cils = msg;
      //   cils.conferenceKeys.forEach((cil) {
      //     print('CheckInAgent:CheckInListsMsg:${cil.url}');
      //     if (!observers.containsKey(cil.url)) {
      //       observers[cil.url] = CheckInObserver(appState: appState, checkInListItem: cil).start(seconds: 0);
      //     }
      //   });
      // }
      // if (msg is FoundTickets) {
      //   final FoundTickets fts = msg;
      //   fts.ticketConferenceKeys.indexWhere((ft) {
      //     if (ft.ticketAndCheckIns.state == TicketAndCheckInsState.Issueable) {
      //       print('checkIn:${ft.conferenceKey.checkInUrl()}:${ft.ticketAndCheckIns.id}');
      //       http.post(ft.conferenceKey.checkInUrl(),
      //         headers: {
      //            "Accept": "application/json",
      //            "Content-Type": "application/json"
      //         },
      //         body: convert.jsonEncode({
      //             "checkin": {
      //               "ticket_id": ft.ticketAndCheckIns.id
      //             }
      //           })
      //       ).then((res) {
      //         // print('Checkout:${res.statusCode}:${res.body}');
      //         this.appState.bus.add(CheckedInTicket(foundTicket: ft, res: res));
      //       }).catchError((e) {
      //         this.appState.bus.add(CheckedTicketError(foundTicket: ft, error: e));
      //       });
      //       return true;
      //     }
      //     return false;
      //   });
      // }
      //     curl --request DELETE \
      // --url 'https://checkin.tito.io/checkin_lists/wech/checkins/6e16a93c-df5e-4105-b535-28e029027696' \
      // --header 'Accept: application/json' \
      // --header 'Content-Type: application/json'
      // if (msg is CheckInListsMsg) {
      //   // msg.lists
      //   //   .where((i) => i.ticketsStatus == CheckInListItemTicketsStatus.Fetched)
      //   //   .where((i) => !observers.containsKey(i.url))
      //   //   .forEach((i) {
      //   //     observers.putIfAbsent(i.url, CheckInObserver.start(i));
      //   //   });
      //   observers.values.forEach((cio) {

      //   });

      //   msg.lists.
      //     .where((i) => i.ticketsStatus == CheckInListItemTicketsStatus.Fetched)
      // }
    });
    return this;
  }
}
