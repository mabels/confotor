import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:confotor/ticket-and-checkins.dart';
import 'package:confotor/ticket-store.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
// import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
import './confotor-app.dart';
import './ticket.dart';
import './tickets.dart';

import 'check-in-agent.dart';
import 'confotor-msg.dart';

class CheckInListMsg extends ConfotorMsg {}

class CheckInListsMsg extends CheckInListMsg {
  final List<CheckInListItem> lists;
  CheckInListsMsg({List<CheckInListItem> lists}) : lists = lists;
}

class CheckInListItemError extends CheckInListMsg implements ConfotorErrorMsg {
  final dynamic error;
  CheckInListItemError({dynamic error}) : error = error;
}

class CheckInListsRemove extends CheckInListMsg {
  final List<CheckInListItem> items;
  CheckInListsRemove({List<CheckInListItem> items}) : items = items;
}

class CheckInListItemRemoved extends ConfotorMsg {
  final CheckInListItem item;
  CheckInListItemRemoved({CheckInListItem item}) : item = item;
}

const List<CheckInListItem> empty = [];

class ClickInListsRefresh extends CheckInListMsg {
  final List<CheckInListItem> items;
  ClickInListsRefresh({List<CheckInListItem> items: empty}) : items = items;
}

class CheckInListScanMsg extends ConfotorMsg {}

class CheckInListScanBarcodeMsg extends CheckInListScanMsg {
  final String barcode;
  CheckInListScanBarcodeMsg({String barcode}) : barcode = barcode;
}
// class TicketListScanPlatformExceptionMsg extends TicketListScanMsg {
//   final PlatformException exception;
//   TicketListScanPlatformExceptionMsg({PlatformException exception}): exception = exception;
// }

// class TicketListScanFormatExceptionMsg extends TicketListScanMsg {
//   final FormatException exception;
//   TicketListScanFormatExceptionMsg({FormatException exception}): exception = exception;
// }

class CheckInListScanUnknownExceptionMsg extends CheckInListScanMsg {
  final dynamic exception;
  CheckInListScanUnknownExceptionMsg({dynamic exception})
      : exception = exception;
}

enum CheckInListItemTicketsStatus { Initial, Fetched }




enum TicketAndCheckInsState {
  Used,
  Issueable,
  Issued,
  Error
}



class CheckInListItem extends CheckInListMsg {
  String url;
  String event_title;
  String expires_at;
  String expires_at_timestamp;
  String tickets_url;
  String checkin_list_url;
  String sync_url;
  int total_pages;
  int total_entries;

  TicketStore ticketStore;

  static Future<CheckInListItem> fetch(String url) async {
    var response = await http.get(url);
    if (200 <= response.statusCode && response.statusCode < 300) {
      var jsonResponse = json.decode(response.body);
      return CheckInListItem.create(url, jsonResponse);
    }
    throw new Exception('CheckInListItem:fetch:$url');
  }

  static CheckInListItem create(String url, dynamic json) {
    var checkInList = new CheckInListItem();
    checkInList.url = url;
    checkInList.event_title = json['event_title'];
    checkInList.expires_at = json['expires_at'];
    checkInList.expires_at_timestamp = json['expires_at_timestamp'];
    checkInList.tickets_url = json['tickets_url'];
    checkInList.checkin_list_url = json['checkin_list_url'];
    checkInList.sync_url = json['sync_url'];
    checkInList.total_pages = json['total_pages'];
    checkInList.total_entries = json['total_entries'];
    checkInList.ticketStore.fromJson(json['tickets']);

    return checkInList;
  }

  get shortEventTitle {
    return event_title.split(" ").first;
  }

}

  String get jsonTicketStatus {
    switch (this.ticketsStatus) {
      case CheckInListItemTicketsStatus.Initial:
        return 'Initial';
      case CheckInListItemTicketsStatus.Fetched:
        return 'Fetched';
    }
  }

  Map<String, dynamic> toJson() {
    List<TicketAndCheckIns> my = ticketAndCheckIns.values.toList();
    // print('toJson:${ticketAndCheckIns.length}');
    // ticketAndheckIns = [];
    return {
        "url": url,
        "event_title": event_title,
        "expires_at": expires_at,
        "expires_at_timestamp": expires_at_timestamp,
        "tickets_url": tickets_url,
        "checkin_list_url": checkin_list_url,
        "sync_url": sync_url,
        "total_pages": total_pages,
        "total_entries": total_entries,
        "ticketsStatus": jsonTicketStatus,
        "tickets": my
      };
  }

  String get listId {
    final url = Uri.parse(this.tickets_url);
    return basename(dirname(url.path));
  }

  String ticketsUrl(int page) {
    // https://ti.to/jsconfeu/jsconf-eu-x-2019/checkin_lists/hello/tickets.json
    return 'https://checkin.tito.io/checkin_lists/$listId/tickets?page=$page';
  }

  String checkInUrl({since: 0, page: 0}) {
    return 'https://checkin.tito.io/checkin_lists/$listId/checkins?since=$since&page=$page';
  }

  String checkOutUrl(String uuid) {
    return "https://checkin.tito.io/checkin_lists/$listId/checkins/$uuid";
  }
}

Future<String> getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

class CheckInListAgent {
  final ConfotorAppState appState;
  final List<CheckInListItem> checkInLists = new List();
  final Map<String, Map<int, Ticket>> ticketsPageTransactions = new Map();
  StreamSubscription subscription;

  CheckInListAgent({ConfotorAppState appState}) : appState = appState;

  Future<File> get _localFile async {
    final path = await getLocalPath();
    print('_localFile:$path');
    return new File('$path/check-in-lists.json');
  }

  Future<List<CheckInListItem>> writeLists(List<CheckInListItem> lists) async {
    final file = await _localFile;
    String str;
    try {
      str = json.encode(lists);
    } on dynamic catch (e) {
       print('JsonEncode:Error:$e');
       return lists;
    }
    try {
      await file.writeAsString(str);
    } on dynamic catch (e) {
       print('WriteLists:Error:$e');
    }
    return lists;
  }

  Future<List<CheckInListItem>> readLists() async {
    try {
      final file = await _localFile;
      final str = await file.readAsString();
      List<dynamic> contents = json.decode(str);
      // print('ReadLists:0:$json:$file:${contents.length}');
      return contents.map((json) {
        // print('ReadLists:1:$json:$file:${contents.length}');
        final ret = CheckInListItem.create(json['url'], json);
        print('ReadLists:$file:${contents.length}:${json['url']}');
        return ret;
      }).toList();
    } catch (e) {
      print('readLists:ERROR:$e');
      return new List<CheckInListItem>();
    }
  }

  stop()  {
    subscription.cancel();
  }

  start() {
    subscription = this.appState.bus.stream.listen((msg) {
      // print('CheckInList:${msg}');
      if (msg is CheckInItemMsg) {
        final idx =
            this.checkInLists.indexWhere((i) => i.url == msg.listItem.url);
        if (idx >= 0) {
          final cil = this.checkInLists[idx];
          var tac = cil.ticketAndCheckIns[msg.item.ticket_id];
          if (tac == null) {
            tac = cil.ticketAndCheckIns.putIfAbsent(msg.item.ticket_id, () {
              return TicketAndCheckIns(ticket: null);
            });
          }
          try {
              // json.encode(msg.item);
              tac.checkInItems.putIfAbsent(msg.item.uuid, () => CheckInItemAndActions(item: msg.item));
              tac.checkInItems[msg.item.uuid].item.update(msg.item);
          } catch (e) {
            print('EncodingError:${msg.item}:${msg.item.uuid}');
          }
        }
      } else if (msg is ConfotorErrorMsg) {
        print('$msg:${(msg as ConfotorErrorMsg).error}');
      } else if (msg is CheckInListScanBarcodeMsg) {
        CheckInListItem.fetch(msg.barcode).then((item) {
          this.appState.bus.add(item);
        }).catchError((e) {
          print('WTF1:$e');
          this.appState.bus.add(new CheckInListItemError(error: e));
        });
        print('Scan BarCode: ${msg.barcode}');
      } else if (msg is CheckInListScanMsg) {
        print('Scan some where Error');
      } else if (msg is CheckInListItem ||
          msg is CheckInListsRemove ||
          msg is TicketsPageMsg ||
          msg is CheckInItemCompleteMsg ||
          msg is ClickInListsRefresh) {
        if (msg is ClickInListsRefresh) {
          this.checkInLists.forEach((checkInList) {
            final idx = msg.items.indexWhere((i) => i.url == checkInList.url);
            if (idx >= 0 || msg.items.isEmpty) {
              checkInList.ticketsStatus = CheckInListItemTicketsStatus.Initial;
              checkInList.ticketAndCheckIns.clear();
            }
          });
        } else if (msg is TicketsPageMsg) {
          var tickets = ticketsPageTransactions[msg.transaction];
          if (tickets == null) {
            ticketsPageTransactions[msg.transaction] = tickets = new Map();
          }
          tickets.addAll(msg.tickets);
          if (msg.completed) {
            ticketsPageTransactions.remove(msg.transaction);
            final idx = this.checkInLists.indexWhere((i) {
              return i.url == msg.checkInListItem.url;
            });
            if (idx >= 0) {
              this.checkInLists[idx].ticketAndCheckIns.clear();
              tickets.values.forEach((t) {
                var tac = this.checkInLists[idx].ticketAndCheckIns[t.id];
                if (tac == null) {
                  tac = TicketAndCheckIns(ticket: t);
                  this.checkInLists[idx].ticketAndCheckIns[t.id] = tac;
                }
                tac.ticket.update(t);
              });
              this.checkInLists[idx].ticketsStatus =
                  CheckInListItemTicketsStatus.Fetched;
            }
          } else {
            return; // don't write incomplete
          }
        } else if (msg is CheckInListItem) {
          final idx = this.checkInLists.indexWhere((i) {
            return i.url == msg.url;
          });
          if (idx >= 0) {
            this.checkInLists[0] = msg;
          } else {
            this.checkInLists.add(msg);
          }
        } else if (msg is CheckInListsRemove) {
          msg.items.forEach((item) {
            final idx = this.checkInLists.indexWhere((i) {
              return i.url == item.url;
            });
            print('CheckInListsRemove:$idx:${item.url}');
            if (idx >= 0) {
              this.checkInLists.removeAt(idx);
              this.appState.bus.add(CheckInListItemRemoved(item: item));
            }
          });
        }
        print('CheckItemLists:${this.checkInLists.length}');
        writeLists(this.checkInLists)
            .then((lists) => this
                .appState
                .bus
                .add(new CheckInListsMsg(lists: lists), persist: true))
            .catchError((e) {
          print('WTF2:$e');
          this.appState.bus.add(new CheckInListItemError(error: e));
        });
      }
    });
    print('Start');
    readLists().then((lists) {
      print('Start-1: ${lists.length}');
      lists.forEach((i) => this.appState.bus.add(i));
    }).catchError((e) {
      print('WTF3:$e');
      this.appState.bus.add(new CheckInListItemError(error: e));
    });
  }
}

checkInListScan({ConfotorBus bus}) {
  BarcodeScanner.scan().then((barcode) {
    bus.add(new CheckInListScanBarcodeMsg(barcode: barcode));
  }).catchError((e) {
    bus.add(new CheckInListScanUnknownExceptionMsg(exception: e));
  });
  // } on PlatformException catch (e) {
  //   bus.add(new TicketListScanPlatformExceptionMsg(exception: e));
  //   // if (e.code == BarcodeScanner.CameraAccessDenied) {
  //   //   setState(() {
  //   //     this.barcode = 'The user did not grant the camera permission!';
  //   //   });
  //   // } else {
  //   //   setState(() => this.barcode = 'Unknown error: $e');
  //   // }
  // } on FormatException catch (e) {
  //   bus.add(new TicketListScanFormatExceptionMsg(exception: e));
  //   // setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
  // } catch (e) {
  //   bus.add(new TicketListScanUnknownExceptionMsg(exception: e));
  //   // setState(() => this.barcode = 'Unknown error: $e');
  // }
}
