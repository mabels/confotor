import 'dart:async';
import 'dart:convert';

import 'package:confotor/agents/paged-observer.dart';
import 'package:confotor/agents/tickets-agent.dart';
import 'package:confotor/confotor-appstate.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mobx/mobx.dart';
import 'package:test_api/test_api.dart';

import '../models/check-in-list-item_test.dart';
import '../models/ticket_test.dart';
import 'test-confotor-app-state.dart';

void main() {
  final ConfotorAppState appState = TestConfotorAppState().start();
  test('observe tickets error response', () async {
    final ta = TicketsAgent(
        appState: appState,
        client: MockClient((request) async {
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/tickets?page=1':
              return Response('status error', 500);
            default:
              expect('XXXX', 'xxxx');
          }
        })).start();

    appState.conferencesAgent.conferences
        .updateFromUrl('test://conf1/checkin_lists/TestConf.json',
            client: MockClient((request) async {
      // print('TestCheckIn: ${request.url}');
      return Response(json.encode(testCheckInList().item), 200);
    }));

    final waitErrorStatus = Completer();
    reaction((_) => appState.conferencesAgent.conferences.values, (vs) {
      if (vs.length > 0) {
        reaction<PagedStatus>(
            (_) => ta.observers.first.value.pagedObserver.status, (status) {
          if (status == PagedStatus.Error) {
            waitErrorStatus.complete();
          }
        }, fireImmediately: true);
      }
    }, fireImmediately: true);

    await waitErrorStatus.future;
    expect(ta.observers.first.value.pagedObserver.error != null, true);
    expect(ta.observers.first.value.pagedObserver.response.statusCode, 500);
  });

  test('observe tickets request exception', () async {
    final ta = TicketsAgent(
        appState: appState,
        client: MockClient((request) async {
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/tickets?page=1':
              throw Exception('Wech');
            default:
              expect('XXXX', 'xxxx');
          }
        })).start();

    appState.conferencesAgent.conferences
        .updateFromUrl('test://conf1/checkin_lists/TestConf.json',
            client: MockClient((request) async {
      // print('TestCheckIn: ${request.url}');
      return Response(json.encode(testCheckInList().item), 200);
    }));

    final waitErrorStatus = Completer();
    reaction((_) => appState.conferencesAgent.conferences.values, (vs) {
      if (vs.length > 0) {
        reaction<PagedStatus>(
            (_) => ta.observers.first.value.pagedObserver.status, (status) {
          if (status == PagedStatus.Error) {
            waitErrorStatus.complete();
          }
        }, fireImmediately: true);
      }
    }, fireImmediately: true);

    await waitErrorStatus.future;
    expect(ta.observers.first.value.pagedObserver.error.message, 'Wech');
    expect(ta.observers.first.value.pagedObserver.response == null, true);
  });

  test('observe tickets invalid json', () async {
    final ta = TicketsAgent(
        appState: appState,
        client: MockClient((request) async {
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/tickets?page=1':
              return Response('][', 200);
            default:
              expect('XXXX', 'xxxx');
          }
        })).start();

    appState.conferencesAgent.conferences
        .updateFromUrl('test://conf1/checkin_lists/TestConf.json',
            client: MockClient((request) async {
      // print('TestCheckIn: ${request.url}');
      return Response(json.encode(testCheckInList().item), 200);
    }));

    final waitErrorStatus = Completer();
    reaction((_) => appState.conferencesAgent.conferences.values, (vs) {
      if (vs.length > 0) {
        reaction<PagedStatus>(
            (_) => ta.observers.first.value.pagedObserver.status, (status) {
          if (status == PagedStatus.Error) {
            waitErrorStatus.complete();
          }
        }, fireImmediately: true);
      }
    }, fireImmediately: true);
    await waitErrorStatus.future;
    expect(ta.observers.first.value.pagedObserver.error != null, true);
    expect(ta.observers.first.value.pagedObserver.response.statusCode, 200);
  });

  test('observe tickets real data', () async {
    final waitTicketsComplete = Completer();
    final ta = TicketsAgent(
        appState: appState,
        client: MockClient((request) async {
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/tickets?page=1':
              return Response(
                  json.encode([1, 2, 3, 4, 5]
                      .map((i) => testTicket(ticketId: i))
                      .toList()),
                  200);
            case 'https://checkin.tito.io/checkin_lists/TestConf/tickets?page=2':
              return Response(
                  json.encode([5, 4, 3, 2, 1, 6]
                      .map((i) => testTicket(ticketId: i))
                      .toList()),
                  200);
            case 'https://checkin.tito.io/checkin_lists/TestConf/tickets?page=3':
              waitTicketsComplete.complete();
              return Response(
                  json.encode([].map((i) => testTicket(ticketId: i)).toList()),
                  200);
            default:
              expect('XXXX', request.url.toString());
          }
        })).start();

    appState.conferencesAgent.conferences
        .updateFromUrl('test://conf1/checkin_lists/TestConf.json',
            client: MockClient((request) async {
      // print('TestCheckIn: ${request.url}');
      return Response(json.encode(testCheckInList().item), 200);
    }));

    await waitTicketsComplete.future;

    final waitErrorStatus = Completer();
    reaction((_) => appState.conferencesAgent.conferences.values, (vs) {
      if (vs.length > 0) {
        reaction<PagedStatus>(
            (_) => ta.observers.first.value.pagedObserver.status, (status) {
          if (status == PagedStatus.Idle) {
            waitErrorStatus.complete();
          }
        }, fireImmediately: true);
      }
    }, fireImmediately: true);

    await waitErrorStatus.future;
    expect(ta.observers.first.value.pagedObserver.status, PagedStatus.Idle);
    expect(ta.observers.first.value.pagedObserver.error == null, true);
    expect(
        appState.conferencesAgent.conferences.first.ticketAndCheckInsLength, 6);
    expect(
        appState.conferencesAgent.conferences.first.ticketAndCheckInsList
            .map((tac) => tac.ticket)
            .toList(),
        [1, 2, 3, 4, 5, 6].map((i) => testTicket(ticketId: i)).toList());
  });
}
