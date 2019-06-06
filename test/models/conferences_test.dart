import 'dart:convert';

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
    final confs = Conferences(conferences: []);
    print('hallo:${confs.values.length}');
    final confReactionDisposer = [];
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
        expect(conf.error is Error, true);
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
        expect(conf.checkInList.item, {});
        expect(conf.error, null);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, {});
        expect(conf.error, null);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url');
        expect(conf.checkInList.item, {});
        expect(conf.error, null);
      },
      (Conference conf) {
        // Shell: hallo:test://url:Exception: CheckInList:fetch:404:test://url:null
        expect(conf.url, 'test://url1');
        expect(conf.checkInList.item, {});
        expect(conf.error, null);
      }
    ];
    final ret = Future(() {
      final my = Future();
      final dispose = reaction<Iterable<Conference>>((_) => confs.values,
          (Iterable<Conference> vs) {
        confReactionDisposer.forEach((f) => f());
        confReactionDisposer.clear();
        confReactionDisposer.addAll(vs.map((conf) {
          // print('Reaction for ${conf.url}');
          return reaction((_) {
            return {"error": conf.error, "checkInList": conf.checkInList.item};
            // pri
            // final error = conf.error;
            // conf.checkInList.item;
            // return true;
          }, (_) {
            expectations.removeAt(0)(conf);
          }, fireImmediately: true);
        }));
        // print('hallo:${v.length}:${v.map((i) => i.url)}');
      });
      return my;
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
      return Response(json.encode(testCheckInList().item), 200);
    }));
    expect(confs.values.length, 1);
    // ok other url
    await confs.updateFromUrl('test://url1',
        client: MockClient((request) async {
      return Response(json.encode(testCheckInList().item), 200);
    }));
    expect(confs.values.length, 2);
    return ret;
  });
}
