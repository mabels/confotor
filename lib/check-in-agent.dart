import 'dart:async';

import 'package:confotor/app-lifecycle-agent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:confotor/check-in-list.dart';
import 'package:confotor/confotor-app.dart';
import 'package:confotor/confotor-msg.dart';
import 'package:confotor/tickets.dart';

class CheckInItem {
  int  id;
  String uuid;
  int ticket_id;
  DateTime created_at;
  DateTime updated_at;
  DateTime deleted_at;

  update(CheckInItem oth) {
    if (!(uuid == oth.uuid && id == oth.id && ticket_id == oth.ticket_id)) {
      throw Exception("Update Object with non matching uuid");
    }
    created_at = oth.created_at;
    updated_at = oth.updated_at;
    deleted_at = oth.deleted_at;
  }

  static CheckInItem fromJson(dynamic json) {
    final ret = CheckInItem();
    ret.id = json['id'];
    ret.uuid = json['uuid'];
    ret.ticket_id = json['ticket_id'];
    ret.created_at = json["created_at"] == null ? null : DateTime.parse(json["created_at"]);
    ret.updated_at = json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]);
    ret.deleted_at = json["deleted_at"] == null ? null : DateTime.parse(json["deleted_at"]);
    return ret;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
    "ticket_id": ticket_id,
    "created_at": created_at != null ? created_at.toIso8601String() : null,
    "updated_at": deleted_at != null ? updated_at.toIso8601String() : null,
    "deleted_at": deleted_at != null ? deleted_at.toIso8601String() : null
  };


  DateTime get maxDate {
    var max = created_at;
    if (updated_at != null && updated_at.compareTo(max) > 0) {
      max = updated_at;
    }
    if (deleted_at != null && deleted_at.compareTo(max) > 0) {
      max = deleted_at;
    }
    return max;
  }
}

class CheckInItemCompleteMsg extends ConfotorMsg {
  final CheckInListItem listItem;
  CheckInItemCompleteMsg({CheckInListItem listItem}):
    listItem = listItem;
}
class CheckInItemMsg extends ConfotorMsg {
  final CheckInListItem listItem;
  final CheckInItem item;
  CheckInItemMsg({CheckInListItem listItem, CheckInItem item}):
    listItem = listItem, item = item;
}

class CheckInObserverError extends ConfotorMsg implements ConfotorErrorMsg {
  final CheckInListItem listItem;
  final dynamic error;
  CheckInObserverError({dynamic error, CheckInListItem listItem}):
    error = error, listItem = listItem;
}

class CheckInObserver {
  final ConfotorAppState appState;
  final CheckInListItem checkInListItem;
  Timer timer;
  int count = 0;
  DateTime since;
  DateTime nextSince;
  CheckInObserver({ConfotorAppState appState, CheckInListItem checkInListItem}):
    checkInListItem = checkInListItem, appState = appState;

  getPage(int page) {
    final url = checkInListItem.checkInUrl(since: since == null ? 0 : since.millisecondsSinceEpoch/1000, page: page);
    http.get(url).then((res) {
      List<dynamic> json = convert.jsonDecode(res.body);
      print('getPage:$url:$page:${json.length}');
      if (json.length != 0) {
        json.forEach((i) {
          final item = CheckInItem.fromJson(i);
          if (nextSince == null) {
            nextSince = item.maxDate;
          } else {
            nextSince = item.maxDate.compareTo(nextSince) > 0 ? item.maxDate : nextSince;
          }
          appState.bus.add(CheckInItemMsg(item: item, listItem: checkInListItem));
          ++count;
        });
        getPage(page + 1);
      } else {
        if (count > 0) {
          appState.bus.add(CheckInItemCompleteMsg(listItem: checkInListItem));
          since = nextSince;
          count = 0;
        }
        nextSince = null;
        start();
      }
    }).catchError((err) {
      appState.bus.add(CheckInObserverError(error: err, listItem: checkInListItem));
    });
  }

  CheckInObserver start({int seconds = 5}) {
    stop();
    timer = new Timer(Duration(seconds: seconds), () {
      getPage(1); // paged api triggered by page 1
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

class CheckedInResponse {
  int id;
  int checkin_list_id;
  int ticket_id;
  String created_at;
  String updated_at;
  String uuid_bin;
  String deleted_at;
  String uuid;

  static CheckedInResponse create(http.Response res) {
    print('CheckedInResponse:${res.body}');
    var cir = new CheckedInResponse();
    var json = convert.jsonDecode(res.body);
    cir.id = json['id'];
    cir.checkin_list_id = json['checkin_list_id'];
    cir.ticket_id = json['ticket_id'];
    cir.created_at = json['created_at'];
    cir.updated_at = json['updated_at'];
    cir.uuid_bin = json['uuid_bin'];
    cir.deleted_at = json['deleted_at'];
    cir.uuid = json['uuid'];
    return cir;
  }

}
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
  final Map<String, CheckInObserver> observers = new Map();

  CheckInAgent({ConfotorAppState appState}): appState = appState;
  StreamSubscription subscription;

  stop() {
    subscription.cancel();
  }

  CheckInAgent start() {
    subscription = this.appState.bus.listen((msg) {
      if (msg is AppLifecycleMsg) {
        switch (msg.state) {
          // case AppLifecycleState.inactive:
          case AppLifecycleState.paused:
            observers.values.forEach((o) { o.stop(); });
            break;
          case AppLifecycleState.suspending:
          case AppLifecycleState.resumed:
            observers.values.forEach((o) { o.start(seconds: 0); });
            break;
          case AppLifecycleState.inactive:
            break;
        }
      }
      if (msg is CheckInListItemRemoved) {
        if (observers.containsKey(msg.item.url)) {
          observers[msg.item.url].stop();
          observers.remove(msg.item.url);
        }
      }
      if (msg is RequestCheckOutTicket) {
        final FoundTicket ft = msg.foundTicket;
        if (ft.checkedIns.last is CheckedInTicket) {
          http.delete(ft.checkInListItem.checkOutUrl(ft.checkedIns.last.checkedIn.uuid)).then((res) {
              this.appState.bus.add(CheckedOutTicket(foundTicket: ft, res: res));
            }).catchError((e) {
              this.appState.bus.add(CheckedTicketError(foundTicket: ft, error: e));
            });
        }
      }
      if (msg is CheckedInTicket) {
        final CheckedInTicket cit = msg;
        if (!observers.containsKey(cit.foundTicket.checkInListItem.url)) {
          observers[cit.foundTicket.checkInListItem.url].start(seconds: 0);
        }
      }
      if (msg is CheckInListsMsg) {
        final CheckInListsMsg cils = msg;
        cils.lists.forEach((cil) {
          print('CheckInAgent:CheckInListsMsg:${cil.url}');
          if (!observers.containsKey(cil.url)) {
            observers[cil.url] = CheckInObserver(appState: appState, checkInListItem: cil).start(seconds: 0);
          }
        });
      }
      if (msg is FoundTickets) {
        final FoundTickets fts = msg;
        fts.tickets.indexWhere((ft) {
          if (ft.state == TicketAndCheckInsState.Issueable) {
            print('checkIn:${ft.checkInListItem.checkInUrl()}:${ft.ticket.id}');
            http.post(ft.checkInListItem.checkInUrl(),
              headers: {
                 "Accept": "application/json",
                 "Content-Type": "application/json"
              },
              body: convert.jsonEncode({
                  "checkin": {
                    "ticket_id": ft.ticket.id
                  }
                })
            ).then((res) {
              // print('Checkout:${res.statusCode}:${res.body}');
              this.appState.bus.add(CheckedInTicket(foundTicket: ft, res: res));
            }).catchError((e) {
              this.appState.bus.add(CheckedTicketError(foundTicket: ft, error: e));
            });
            return true;
          }
          return false;
        });
      }
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