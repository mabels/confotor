import 'dart:async';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CheckInListObserver {
  final ConfotorAppState appState;
  final CheckInList checkInList;
  Timer timer;
  // int count = 0;
  DateTime since;
  DateTime nextSince;

  CheckInListObserver(
      {@required ConfotorAppState appState, @required CheckInList checkInList})
      : checkInList = checkInList,
        appState = appState;

  getPage(int page, String transaction) {
    final url = checkInList.checkInUrl(
        since: since == null ? 0 : since.millisecondsSinceEpoch / 1000,
        page: page);
    http.get(url).then((res) {
      // print('getPage:$url:$page:pre');
      List<dynamic> json = convert.jsonDecode(res.body);
      // print('getPage:$url:$page:${json.length}');
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
      if (items.isNotEmpty) {
        print('getPage:$url:$page:${items.length}');
      }
      appState.bus.add(CheckInItemPageMsg(
        checkInList: checkInList,
        transaction: transaction,
        items: items.toList(),
        page: page,
        completed: items.isEmpty,
      ));
      // print('getPage:$url:$page:pos:1');
      if (items.isNotEmpty) {
        // print('getPage:$url:$page:pos:2');
        getPage(page + 1, transaction);
      } else {
        // print('getPage:$url:$page:pos:3:$nextSince');
        since = nextSince;
        // nextSince = null;
        start();
      }
    }).catchError((err) {
      appState.bus.add(CheckInObserverError(
          error: err, conference: checkInList, transaction: transaction));
    });
  }

  CheckInListObserver start({int seconds = 5}) {
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

class CheckInListAgent {
  final ConfotorAppState appState;
  final Map<String /* url */, CheckInListObserver> observers = new Map();
  StreamSubscription subscription;

  CheckInListAgent({@required ConfotorAppState appState}) : appState = appState;

  stop() {
    subscription.cancel();
  }

  CheckInListAgent start() {
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
        // print('CheckInListAgent:UpdatedConference:${msg.checkInList.url}');
        if (!observers.containsKey(msg.checkInList.url)) {
          // print('CheckInListAgent:UpdatedConference:${msg.checkInList.url}:create');
          observers[msg.checkInList.url] = CheckInListObserver(
              appState: appState, checkInList: msg.checkInList);
          observers[msg.checkInList.url].start(seconds: 0);
        } else {
          // reload list
          // print('CheckInListAgent:UpdatedConference:${msg.checkInList.url}:refresh');
          observers[msg.checkInList.url].stop();
          observers[msg.checkInList.url].start(seconds: 0);
        }
      }

      if (msg is RemovedConference) {
        if (observers.containsKey(msg.checkInList.url)) {
          observers[msg.checkInList.url].stop();
          observers.remove(msg.checkInList.url);
        }
      }

    });
    return this;
  }
}
