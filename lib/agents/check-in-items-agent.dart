import 'dart:ui';

import 'package:confotor/models/conference.dart';
import 'package:confotor/models/transaction.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';
import 'check-in-items-observer.dart';

class CheckInItemsAgent {
  final ConfotorAppState _appState;
  final List<Transaction<CheckInItemsObserver>> observers = List();
  final BaseClient _client;
  ReactionDisposer _appLifecycleDisposer;
  ReactionDisposer _conferenceDisposer;

  CheckInItemsAgent({@required ConfotorAppState appState, BaseClient client})
      : _appState = appState,
        _client = client;

  stop() {
    observers.forEach((o) => o.value.stop());
    observers.clear();
    _appLifecycleDisposer();
    _conferenceDisposer();
  }

  CheckInItemsAgent start({Duration pollInterval}) {
    pollInterval = pollInterval == null ? Duration(seconds: 5) : pollInterval;
    _appLifecycleDisposer =
        reaction((_) => _appState.appLifecycleAgent.state, (state) {
      switch (state) {
        // case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
          observers.forEach((o) {
            o.value.stop();
          });
          break;
        case AppLifecycleState.suspending:
        case AppLifecycleState.resumed:
          observers.forEach((o) {
            o.value.start(pollInterval: pollInterval);
          });
          break;
        case AppLifecycleState.inactive:
          break;
      }
    });
    _conferenceDisposer = reaction<Iterable<Conference>>(
        (_) => _appState.conferencesAgent.conferences.values, (vs) {
      final transaction = _appState.uuid.v4();
      final List<Conference> confs = List.from(vs);
      observers.forEach((obs) {
        final preLength = confs.length;
        confs.removeWhere((i) => obs.value.url == i.url);
        if (preLength != confs.length) {
          // print('restart:${obs.value.url}');
          obs.transaction = transaction;
          obs.value.start(pollInterval: pollInterval); // restart
        }
      });
      confs.forEach((conf) {
        // print('start:${conf.url}');
        observers.add(Transaction(
            transaction: transaction,
            value: CheckInItemsObserver(
                    appState: _appState, conference: conf, client: _client)
                .start(pollInterval: pollInterval)));
      });
      // remove unsed
      observers.removeWhere((o) => o.transaction != transaction);
    }, fireImmediately: true);
    return this;
  }

  // addConference()

  //   subscription = this.appState.bus.listen((msg) {
  //     if (msg is UpdatedConference) {
  //       // print('CheckInListAgent:UpdatedConference:${msg.checkInList.url}');
  //       if (!observers.containsKey(msg.checkInList.url)) {
  //         // print('CheckInListAgent:UpdatedConference:${msg.checkInList.url}:create');
  //         observers[msg.checkInList.url] = CheckInListObserver(
  //             appState: appState, checkInList: msg.checkInList);
  //         observers[msg.checkInList.url].start(seconds: 0);
  //       } else {
  //         // reload list
  //         // print('CheckInListAgent:UpdatedConference:${msg.checkInList.url}:refresh');
  //         observers[msg.checkInList.url].stop();
  //         observers[msg.checkInList.url].start(seconds: 0);
  //       }
  //     }

  //     if (msg is RemovedConference) {
  //       if (observers.containsKey(msg.checkInList.url)) {
  //         observers[msg.checkInList.url].stop();
  //         observers.remove(msg.checkInList.url);
  //       }
  //     }

  //   });
  //  return this;
  // }
}
