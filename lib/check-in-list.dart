import 'dart:async';
import 'dart:convert' as Convert;
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
import './confotor-app.dart';
import './ticket.dart';
import './tickets.dart';

import 'confotor-msg.dart';

class CheckInListMsg extends ConfotorMsg {}

class CheckInListsMsg extends CheckInListMsg {
  final List<CheckInListItem> lists;
  CheckInListsMsg({List<CheckInListItem> lists}) : lists = lists;
}

class CheckInListItemError extends CheckInListMsg {
  final dynamic error;
  CheckInListItemError({dynamic error}) : error = error;
}

class CheckInListItemRemove extends CheckInListMsg {
  final CheckInListItem item;
  CheckInListItemRemove({CheckInListItem item}) : item = item;
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
  CheckInListItemTicketsStatus ticketsStatus =
      CheckInListItemTicketsStatus.Initial;
  final Map<int, Ticket> tickets = new Map();

  static Future<CheckInListItem> fetch(String url) async {
    var response = await http.get(url);
    if (200 <= response.statusCode && response.statusCode < 300) {
      var jsonResponse = Convert.jsonDecode(response.body);
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
    List<dynamic> ticketsList = json['tickets'];
    if (ticketsList == null) {
      ticketsList = [];
    }
    ticketsList.forEach((jsonTicket) {
      Ticket ticket = Ticket.create(jsonTicket);
      checkInList.tickets[ticket.id] = ticket;
    });
    checkInList.ticketsStatus = ticketsStatusFromJson(json['ticketsStatus']);
    return checkInList;
  }

  static CheckInListItemTicketsStatus ticketsStatusFromJson(String ts) {
    switch (ts) {
      case 'Fetched':
        return CheckInListItemTicketsStatus.Fetched;
      case 'Initial':
      default:
        return CheckInListItemTicketsStatus.Initial;
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

  Map<String, dynamic> toJson() => {
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
        "tickets": tickets.values.toList()
      };

  String ticketsUrl(int page) {
    final url = Uri.parse(this.tickets_url);
    final listId = basename(dirname(url.path));
    // https://ti.to/jsconfeu/jsconf-eu-x-2019/checkin_lists/hello/tickets.json
    return 'https://checkin.tito.io/checkin_lists/$listId/tickets?page=$page';
  }
}

Future<String> getLocalPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

class CheckInListAgent {
  final ConfotorAppState appState;
  final List<CheckInListItem> checkInLists = new List();

  CheckInListAgent({ConfotorAppState appState}) : appState = appState;

  Future<File> get _localFile async {
    final path = await getLocalPath();
    print('_localFile:$path');
    return new File('$path/check-in-lists.json');
  }

  Future<List<CheckInListItem>> writeLists(List<CheckInListItem> lists) async {
    final file = await _localFile;
    final json = Convert.jsonEncode(lists);
    final x = await file.writeAsString(json);
    print('WriteLists:$json:$x');
    return lists;
  }

  Future<List<CheckInListItem>> readLists() async {
    try {
      final file = await _localFile;
      final json = await file.readAsString();
      List<dynamic> contents = Convert.jsonDecode(json);
      print('ReadLists:0:$json:$file:${contents.length}');
      return contents.map((json) {
        print('ReadLists:1:$json:$file:${contents.length}');
        final ret = CheckInListItem.create(json['url'], json);
        print('ReadLists:2:$json:$file:${contents.length}:${json['url']}:$ret');
        return ret;
      }).toList();
    } catch (e) {
      print('readLists:ERROR:$e');
      return new List<CheckInListItem>();
    }
  }

  start() {
    this.appState.bus.stream.listen((msg) {
      print('CheckInList:${msg}');
      if (msg is CheckInListItemError) {
        print('CheckInListItemError:${msg.error}');
      } else if (msg is CheckInListScanBarcodeMsg) {
        CheckInListItem.fetch(msg.barcode).then((item) {
          this.appState.bus.add(item);
        }).catchError((e) {
          this.appState.bus.add(new CheckInListItemError(error: e));
        });
        print('Scan BarCode: ${msg.barcode}');
      } else if (msg is CheckInListScanMsg) {
        print('Scan some where Error');
      } else if (msg is CheckInListItem ||
          msg is CheckInListItemRemove ||
          msg is TicketsCompleteMsg ||
          msg is ClickInListsRefresh) {
        if (msg is ClickInListsRefresh) {
          this.checkInLists.forEach((checkInList) {
            final idx = msg.items.indexWhere((i) => i.url == checkInList.url);
            if (idx >= 0 || msg.items.isEmpty) {
              checkInList.ticketsStatus = CheckInListItemTicketsStatus.Initial;
              checkInList.tickets.clear();
            }
          });
        } else if (msg is TicketsCompleteMsg) {
          final idx = this.checkInLists.indexWhere((i) {
            return i.url == msg.checkInListItem.url;
          });
          print('CheckInList:${msg}:${msg.tickets.length}:$idx');
          if (idx >= 0) {
            this.checkInLists[idx].tickets.clear();
            this.checkInLists[idx].tickets.addAll(msg.tickets);
            this.checkInLists[idx].ticketsStatus =
                CheckInListItemTicketsStatus.Fetched;
            print('CheckInList:${msg}:${msg.tickets.length}:$idx:PRE');
            // this
            //     .appState
            //     .bus
            //     .add(new CheckInListsMsg(lists: this.checkInLists));
            // print('CheckInList:${msg}:${msg.tickets.length}:$idx:POST');
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
        } else if (msg is CheckInListItemRemove) {
          final idx = this.checkInLists.indexWhere((i) {
            return i.url == msg.item.url;
          });
          if (idx >= 0) {
            this.checkInLists.removeAt(idx);
          }
        }
        print('CheckItemLists:${this.checkInLists.length}');
        writeLists(this.checkInLists)
            .then((lists) =>
                this.appState.bus.add(new CheckInListsMsg(lists: lists)))
            .catchError((e) {
          print('Error:$e');
          this.appState.bus.add(new CheckInListItemError(error: e));
        });
      }
    });
    print('Start');
    readLists().then((lists) {
      print('Start-1: ${lists.length}');
      lists.forEach((i) => this.appState.bus.add(i));
    }).catchError((e) {
      print('Start-2');
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
