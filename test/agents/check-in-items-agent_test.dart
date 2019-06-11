import 'dart:async';
import 'dart:convert';

import 'package:confotor/agents/check-in-items-agent.dart';
import 'package:confotor/agents/paged-observer.dart';
import 'package:confotor/confotor-appstate.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mobx/mobx.dart';
import 'package:test_api/test_api.dart';

import '../models/check-in-item_test.dart';
import '../models/check-in-list-item_test.dart';
import 'test-confotor-app-state.dart';

void main() {
  final ConfotorAppState appState = TestConfotorAppState().start();
  test('observe check-in-items error response', () async {
    final ciia = CheckInItemsAgent(
        appState: appState,
        client: MockClient((request) async {
          // print('XXXX:${request.url}');
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=0':
              return Response('status error', 500);
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

    final waitErrorStatus = Completer();
    reaction((_) => appState.conferencesAgent.conferences.values, (vs) {
      if (vs.length > 0) {
        reaction<PagedStatus>(
            (_) => ciia.observers.first.value.pagedObserver.status, (status) {
          if (status == PagedStatus.Error) {
            waitErrorStatus.complete();
          }
        }, fireImmediately: true);
      }
    }, fireImmediately: true);

    await waitErrorStatus.future;
    expect(ciia.observers.first.value.pagedObserver.error != null, true);
    expect(ciia.observers.first.value.pagedObserver.response.statusCode, 500);
    ciia.stop();
  });

  test('observe CheckInItems request exception', () async {
    final ta = CheckInItemsAgent(
        appState: appState,
        client: MockClient((request) async {
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=0':
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

  test('observe checkinitems invalid json', () async {
    final ciia = CheckInItemsAgent(
        appState: appState,
        client: MockClient((request) async {
          switch (request.url.toString()) {
            case 'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=0':
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
            (_) => ciia.observers.first.value.pagedObserver.status, (status) {
          if (status == PagedStatus.Error) {
            waitErrorStatus.complete();
          }
        }, fireImmediately: true);
      }
    }, fireImmediately: true);
    await waitErrorStatus.future;
    expect(ciia.observers.first.value.pagedObserver.error != null, true);
    expect(ciia.observers.first.value.pagedObserver.response.statusCode, 200);
    ciia.stop();
  });

  test('observe checkinitems real data', () async {
    final waitTicketsComplete = Completer();
    final pollInterval = Duration(milliseconds: 50);
    final DateTime now = DateTime.now();
    DateTime last;
    CheckInItemsAgent ciia;
    final runDown = [
      (request) {
        expect(request.url.toString(),
            'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=0');
        return Response(
            json.encode([1, 2, 3, 4, 5]
                .map((i) => testCheckInItem(ticketId: i))
                .toList()),
            200);
      },
      (request) {
        expect(request.url.toString(),
            'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=1');
        return Response(
            json.encode([5, 4, 3, 2, 1, 6]
                .map((i) =>
                    testCheckInItem(ticketId: i, uuid: 'iii$i', deletedAt: now))
                .toList()),
            200);
      },
      (request) {
        expect(request.url.toString(),
            'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=2');
        return Response(
            json.encode([5, 4, 3, 2, 1]
                .map((i) => testCheckInItem(ticketId: i, updatedAt: now))
                .toList()),
            200);
      },
      (request) {
        expect(request.url.toString(),
            'https://checkin.tito.io/checkin_lists/TestConf/checkins?since=0&page=3');
        return Response(
            json.encode([].map((i) => testCheckInItem(ticketId: i)).toList()),
            200);
      },
      (request) {
        // print('AAAA:${now.millisecondsSinceEpoch / 1000}');
        expect(
            request.url.toString(),
            ciia.observers.first.value.conference.checkInList
                .checkInUrl(page: 0, since: now.millisecondsSinceEpoch / 1000));
        return Response(
            json.encode([].map((i) => testCheckInItem(ticketId: i)).toList()),
            200);
      },
      (request) {
        // print('BBBB:${now.millisecondsSinceEpoch / 1000}');
        expect(
            request.url.toString(),
            ciia.observers.first.value.conference.checkInList
                .checkInUrl(page: 0, since: now.millisecondsSinceEpoch / 1000));
        last = DateTime.now();
        return Response(
            json.encode([2]
                .map((i) => testCheckInItem(ticketId: i, updatedAt: last))
                .toList()),
            200);
      },
      (request) {
        // print('DDDD:${now.millisecondsSinceEpoch / 1000}');
        expect(
            request.url.toString(),
            ciia.observers.first.value.conference.checkInList
                .checkInUrl(page: 1, since: now.millisecondsSinceEpoch / 1000));
        return Response(
            json.encode([]
                .map((i) => testCheckInItem(ticketId: i, updatedAt: now))
                .toList()),
            200);
      },
      (request) {
        // print('CCCC:${last.millisecondsSinceEpoch / 1000}');
        expect(
            request.url.toString(),
            ciia.observers.first.value.conference.checkInList.checkInUrl(
                page: 0, since: last.millisecondsSinceEpoch / 1000));
        ciia.stop();
        Timer(pollInterval, () => waitTicketsComplete.complete());
        return Response(
            json.encode([]
                .map((i) => testCheckInItem(ticketId: i, updatedAt: now))
                .toList()),
            200);
      }
    ];

    ciia = CheckInItemsAgent(
        appState: appState,
        client: MockClient((request) async {
          // print('Mock: ${request.url.toString()}');
          return runDown.removeAt(0)(request);
        })).start(pollInterval: pollInterval);

    // final waitErrorStatus = Completer();
    // reaction((_) => appState.conferencesAgent.conferences.values, (vs) {
    //   if (vs.length > 0) {
    //     reaction<PagedStatus>(
    //         (_) => ciia.observers.first.value.pagedObserver.status, (status) {
    //       print(
    //           'status:$status,${ciia.observers.first.value.pagedObserver.error}');
    //       // if (status == PagedStatus.Idle) {
    //       //   waitErrorStatus.complete();
    //       // }
    //     }, fireImmediately: true);
    //   }
    // }, fireImmediately: true);

    appState.conferencesAgent.conferences
        .updateFromUrl('test://conf1/checkin_lists/TestConf.json',
            client: MockClient((request) async {
      return Response(json.encode(testCheckInList().item), 200);
    }));

    await waitTicketsComplete.future;
    // await waitErrorStatus.future;
    expect(ciia.observers.length, 0);
    expect(
        appState.conferencesAgent.conferences.first.ticketAndCheckInsLength, 6);
    final ref = [
      [
        testCheckInItem(ticketId: 1, uuid: 'iii1', deletedAt: now),
        testCheckInItem(ticketId: 1, uuid: 'uuid1', updatedAt: now),
      ],
      [
        testCheckInItem(ticketId: 2, uuid: 'iii2', deletedAt: now),
        testCheckInItem(ticketId: 2, uuid: 'uuid2', updatedAt: last),
      ],
      [
        testCheckInItem(ticketId: 3, uuid: 'iii3', deletedAt: now),
        testCheckInItem(ticketId: 3, uuid: 'uuid3', updatedAt: now),
      ],
      [
        testCheckInItem(ticketId: 4, uuid: 'iii4', deletedAt: now),
        testCheckInItem(ticketId: 4, uuid: 'uuid4', updatedAt: now),
      ],
      [
        testCheckInItem(ticketId: 5, uuid: 'iii5', deletedAt: now),
        testCheckInItem(ticketId: 5, uuid: 'uuid5', updatedAt: now),
      ],
      [testCheckInItem(ticketId: 6, uuid: 'iii6', deletedAt: now)],
    ];

    final orig = appState
        .conferencesAgent.conferences.first.ticketAndCheckInsList
        .map((tac) => tac.checkInItems.checkInItems.toList())
        .toList();

    // print(json.encode(orig));
    // print(json.encode(ref));
    expect(orig[0][0], ref[0][0], reason: '0,0');
    expect(orig[0][1], ref[0][1], reason: '0,1');
    expect(orig[1][0], ref[1][0], reason: '1,0');
    expect(orig[1][1], ref[1][1], reason: '1,1');
    expect(orig[2][0], ref[2][0], reason: '2,0');
    expect(orig[2][1], ref[2][1], reason: '2,1');
    expect(orig[3][0], ref[3][0], reason: '3,0');
    expect(orig[3][1], ref[3][1], reason: '3,1');
    expect(orig[4][0], ref[4][0], reason: '4,0');
    expect(orig[4][1], ref[4][1], reason: '4,1');
    expect(orig[5][0], ref[5][0], reason: '5,0');
  });
}
