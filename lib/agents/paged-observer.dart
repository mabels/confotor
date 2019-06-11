import 'dart:async';
import 'dart:convert';

import 'package:confotor/models/fix-http-client.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';

part 'paged-observer.g.dart';

enum PagedStatus { Idle, Fetching, Error }

enum PagedStep { Next, Done }
abstract class PagedAction {
  String fetchUrl(String transaction, int page);
  PagedStep process(String transaction, int page, dynamic json);
  Timer nextPoll(void onPoll());
}


// This is the class used by rest of your codebase
class PagedObserver extends PagedObserverBase with _$PagedObserver {
  PagedObserver(
      {@required ConfotorAppState appState,
      BaseClient client})
      : super(appState: appState, client: client);
}

abstract class PagedObserverBase with Store {
  @observable
  PagedStatus status = PagedStatus.Idle;
  @observable
  dynamic error;
  @observable
  Response response;

  final ConfotorAppState _appState;
  final BaseClient _client;
  Timer _timer;
  ReactionDisposer _disposer;
  ReactionDisposer _stopDisposer;

  PagedObserverBase(
      {@required ConfotorAppState appState,
      BaseClient client})
      : _appState = appState,
        _client = client;


  @action
  _thenResponse(PagedAction action, String transaction, int page, String url, Response response) {
    this.response = response;
    // print(
    //     'TicketAgent:getPages:$url:$page:$transaction:${response.statusCode}');
    if (200 <= response.statusCode && response.statusCode < 300) {
      try {
        switch (action.process(transaction, page, json.decode(response.body))) {
          case PagedStep.Next:
            getPages(action, transaction, page + 1);
            break;
          case PagedStep.Done:
            status = PagedStatus.Idle;
            if (action.nextPoll != null) {
              _timer = action.nextPoll(() => getPages(action, _appState.uuid.v4(), 0));
            }
            break;
        }
      } catch (e) {
        status = PagedStatus.Error;
        error = e;
      }
    } else {
      // print("TicketsError:ResponseCode:getPage:$url:${response.statusCode}");
      status = PagedStatus.Error;
      error = Exception("ResponseCode:getPage:$url:${response.statusCode}");
    }
  }

  @action
  getPages(PagedAction action, String transaction, int page) {
    status = PagedStatus.Fetching;
    final url = action.fetchUrl(transaction, page);
    fixHttpClient(_client)
        .get(url)
        .then((response) => _thenResponse(action, transaction, page, url, response))
        .catchError((e) {
      Action(() {
        status = PagedStatus.Error;
        response = null;
        error = e;
      })();
    });
  }

  PagedObserver start(PagedAction action) {
    _disposer = reaction((_) => status, (state) {
      if (state == PagedStatus.Idle || state == PagedStatus.Error) {
        if (_disposer != null) {
          _disposer();
          _disposer = null;
        }
        if (_timer != null) {
            _timer.cancel();
            _timer = null;
        }
        getPages(action, _appState.uuid.v4(), 0); // paged api triggered by page 1
        return this;
      }
    }, fireImmediately: true);
    return this;
  }

  stop() {
    if (_disposer != null) {
      _disposer();
      _disposer = null;
    }
    if (_stopDisposer == null) {
      _stopDisposer = reaction((_) => status, (state) {
        if (state == PagedStatus.Idle || state == PagedStatus.Error) {
          // print('PagedObserver:STOPPINNG:$_timer');
          if (_timer != null) {
            _timer.cancel();
            _timer = null;
          }
          _stopDisposer();
          _stopDisposer = null;
        }
      }, fireImmediately: true);
    }
  }
}
