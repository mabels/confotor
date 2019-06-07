import 'dart:async';
import 'dart:convert';

import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mobx/mobx.dart';
import 'package:test_api/test_api.dart';

import 'check-in-list-item_test.dart';
import 'ticket-and-checkins_test.dart';

void main() {
  test("Conferences isEmpty", () {
    final confs = Conferences(conferences: []);
    expect(confs.isEmpty, true);
  });

  test("Conferences !isEmpty", () {
    final confs = Conferences(conferences: [
      Conference(
          checkInList: testCheckInList(),
          ticketAndCheckInsList: [testTicketAndCheckins()])
    ]);
    expect(confs.isEmpty, false);
  });

  test('Serialize', () {
    final confs = Conferences(conferences: [
      Conference(checkInList: testCheckInList(), ticketAndCheckInsList: [])
    ]);
    final str = json.encode(confs);
    final refCia = Conferences.fromJson(json.decode(str));
    expect(confs.first.url, refCia.first.url);
  });

  test('updateFromUrl', () async {
    // print('Enter Master');
    final confs = Conferences(conferences: []);
    // print('hallo:${confs.values.length}');
    final expectations = [
      (Conference conf) {
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, null);
        expect(conf.error is Error, true);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: Unknown Error:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, null);
        expect(conf.error is Exception, true);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, null);
        expect(conf.error is Exception, true);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, CheckInListItem(
          eventTitle: null,
          expiresAt: null,
          expiresAtTimestamp: null,
          ticketsUrl: null,
          checkinListUrl: null,
          syncUrl: null,
          totalEntries: null,
          totalPages: null
        ));
        expect(conf.error, null);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, testCheckInList().item);
        expect(conf.error, null);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, testCheckInList(eventTitle: 'ooo').item);
        expect(conf.error, null);
      },
      /* add url1 */
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, testCheckInList(eventTitle: 'ooo').item);
        expect(conf.error, null);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url1');
        expect(conf.checkInList.item, testCheckInList().item);
        expect(conf.error, null);
      }
    ];
    final backToTest = StreamController<Conference>();
    final confReactionDisposer = [];
    // print('xxxx-1');
    final completer = Completer();
    ReactionDisposer dispose;
    dispose = reaction<Iterable<Conference>>((_) {
      // print('xxxx-2');
      return confs.values;
    }, (Iterable<Conference> vs) {
      confReactionDisposer.forEach((f) => f());
      confReactionDisposer.clear();
      confReactionDisposer.addAll(vs.map((conf) {
        // print('Reaction for ${conf.url}');
        return reaction(
            (_) => {"error": conf.error, "checkInList": conf.checkInList.item},
            (_) {
          backToTest.add(conf);
        }, fireImmediately: true);
      }));
      // print('hallo:${v.length}:${v.map((i) => i.url)}');
    });

    backToTest.stream.listen((conf) {
      // print('Conference Reaction ${conf.url}:${expectations.length}');
      try {
        expectations.removeAt(0)(conf);
      } catch (e) {
        confReactionDisposer.forEach((f) => f());
        dispose();
        completer.completeError(e);
      }
      if (expectations.length == 0) {
        confReactionDisposer.forEach((f) => f());
        dispose();
        completer.complete();
      }
    });
    // print('hallo:${confs.values.length}');
    // url error case
    await confs.updateFromUrl('test://url');
    expect(confs.values.length, 1);
    // error case
    await confs.updateFromUrl('test://url', client: MockClient((request) {
      throw Exception('Unknown Error');
    }));
    expect(confs.values.length, 1);
    // status code 400
    await confs.updateFromUrl('test://url', client: MockClient((request) async {
      return Response('jojo', 404);
    }));
    expect(confs.values.length, 1);
    // defect json
    await confs.updateFromUrl('test://url', client: MockClient((request) async {
      return Response(json.encode({"meno": 4}), 200);
    }));
    expect(confs.values.length, 1);
    // ok json
    await confs.updateFromUrl('test://url', client: MockClient((request) async {
      return Response(json.encode(testCheckInList().item), 200);
    }));
    expect(confs.values.length, 1);
    // ok double
    await confs.updateFromUrl('test://url', client: MockClient((request) async {
      return Response(json.encode(testCheckInList(eventTitle: 'ooo').item), 200);
    }));
    expect(confs.values.length, 1);
    // ok other url
    await confs.updateFromUrl('test://url1', client: MockClient((request) async {
      return Response(json.encode(testCheckInList().item), 200);
    }));
    expect(confs.values.length, 2);
    // print('Exit Master');
    return completer.future;
  });
}
