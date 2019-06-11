import 'dart:async';

import 'package:confotor/agents/paged-observer.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';

part 'check-in-items-observer.g.dart';

class CheckInItemsPagedAction extends PagedAction {
  final Conference _conference;
  final PagedObserver _pagedObserver;
  final Duration _pollInterval;
  DateTime since;
  DateTime nextSince;

  CheckInItemsPagedAction({
     @required Conference conference,
     @required Duration pollInterval,
     @required PagedObserver pagedObserver
  })
      : _conference = conference, _pagedObserver = pagedObserver, _pollInterval = pollInterval {
        _pagedObserver.start(this);
      }

  @override
  String fetchUrl(String transaction, int page) {
    return _conference.checkInList.checkInUrl(
        since: since == null ? 0 : since.millisecondsSinceEpoch / 1000,
        page: page);
  }

  @override
  Timer nextPoll(void Function() onPoll) {
    if (_pollInterval != null) {
      return Timer(_pollInterval, () => _pagedObserver.start(this));
    }
    return null;
  }

  @override
  PagedStep process(String transaction, int page, json) {
    final Iterable<CheckInItem> items = (json as Iterable<dynamic>).map((i) {
      final item = CheckInItem.fromJson(i);
      if (nextSince == null) {
        nextSince = item.maxDate;
      } else {
        nextSince =
            item.maxDate.compareTo(nextSince) > 0 ? item.maxDate : nextSince;
      }
      return item;
    });
    _conference.updateCheckInItems(transaction, items);
    if (items.isNotEmpty) {
      return PagedStep.Next;
    } else {
      // print('getPage:$url:$page:pos:3:$nextSince');
      since = nextSince;
      return PagedStep.Done;
    }
  }
}

class CheckInItemsObserver extends CheckInItemsObserverBase
    with _$CheckInItemsObserver {
  CheckInItemsObserver({
    @required ConfotorAppState appState, 
    @required Conference conference, 
    BaseClient client})
      : super(appState: appState, client: client, conference: conference);
}

abstract class CheckInItemsObserverBase with Store {
  final PagedObserver pagedObserver;
  final Conference conference;

  CheckInItemsObserverBase(
      {@required ConfotorAppState appState, BaseClient client,
       @required Conference conference})
      : conference = conference,
        pagedObserver = PagedObserver(appState: appState, client: client);

  String get url => conference.url;

  CheckInItemsObserver start({@required Duration pollInterval}) {
    CheckInItemsPagedAction(
        conference: conference,
        pollInterval: pollInterval,
        pagedObserver: pagedObserver);
    return this;
  }

  stop() {
    pagedObserver.stop();
  }
}
