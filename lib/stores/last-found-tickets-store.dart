import 'dart:convert';
import 'dart:io';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:meta/meta.dart';

class LastFoundTicketsStore {
  final ConfotorAppState appState;
  final List<FoundTickets> last = [];
  int maxLen;

  LastFoundTicketsStore({@required ConfotorAppState appState, int maxLen = 20})
      : maxLen = maxLen,
        appState = appState;

  LastFoundTickets toLastFoundTickets() {
    return LastFoundTickets(last: last, maxLen: maxLen);
  }

  LastFoundTicketsStore update(LastFoundTickets lft) {
    maxLen = lft.maxLen;
    lft.last.forEach((lt) => updateFoundTickets(lt));
    return this;
  }

  LastFoundTicketsStore updateFoundTickets(FoundTickets oth) {
    final idx = last.indexWhere((t) => t.slug == oth.slug);
    if (idx >= 0) {
      last.removeAt(idx);
    }
    this.last.insert(0, oth);
    for (var i = maxLen; i < last.length; i++) {
      last.removeLast();
    }
    return this;
  }

  Future<File> get fileName async {
    final path = await appState.getLocalPath();
    return new File('$path/last-ticket-store.json');
  }

  write() {
    fileName.then((file) {
      String str;
      try {
        str = json.encode({"lastFoundTickets": toLastFoundTickets()});
      } on dynamic catch (e) {
        print('JsonEncode:Error:$e');
        return this;
      }
      file.writeAsString(str)
        .then((file) {
          print('lastfoundtickets:write:$file:$str');
        })
        .catchError((e) => print('lastfoundtickets:Error:$e'));
    });
  }

  void read() {
    /*
    .then((confs) {
      confs.values.forEach((conf) => this.appState.bus.add(RequestUpdateConference(checkInListItem: conf.checkInListItem)));
    }).catchError((e) {
    });
    */
    fileName.then((file) {
      file.readAsString().then((str) {
        try {
          print('read:$file:$str');
          appState.bus
              .add(JsonObject(json: json.decode(str), fileName: file.path));
        } catch (e) {
          appState.bus
              .add(JsonObjectError(error: e, str: str, fileName: file.path));
        }
      }).catchError((e) {
        appState.bus.add(new FileError(error: e, fileName: file.path));
      });
    }).catchError((e) {
      appState.bus.add(new FileError(error: e));
    });
  }
}
