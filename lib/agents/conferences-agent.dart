
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:confotor/agents/tickets-agent.dart';
import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:confotor/msgs/scan-msg.dart';
import 'package:meta/meta.dart';

import 'check-in-agent.dart';

class ConferencesAgent {
  final ConfotorAppState appState;
  final Conferences _conferences = Conferences();

  StreamSubscription subscription;

  ConferencesAgent({@required ConfotorAppState appState}) : appState = appState;

  Future<File> get _localFile async {
    final path = await appState.getLocalPath();
    print('_localFile:$path');
    return new File('$path/check-in-lists.json');
  }

  Future<Conferences> writeLists(Conferences lists) async {
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

  Future<Conferences> readConferences() async {
    try {
      final file = await _localFile;
      final str = await file.readAsString();
      List<dynamic> contents = json.decode(str);
      // print('ReadLists:0:$json:$file:${contents.length}');
      contents.forEach((json) {
        // print('ReadLists:1:$json:$file:${contents.length}');
        final ret = _conferences.updateConferenceFromJson(json);
        print('ReadLists:$file:${contents.length}:${json['url']}');
        return ret;
      });
    } catch (e) {
      print('readLists:ERROR:$e');
      appState.bus.add(ConferencesError(error: e));
    }
    return _conferences;
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
      } else
      
      
      if (msg is ScanTicketMsg) {
        ScanTicketMsg tsmsg = msg;
        final found = _conferences.findTickets(tsmsg.barcode);
        this.appState.bus.add(found);
        print('TicketScanBarcodeMsg:$found');
      } else if (msg is ConfotorErrorMsg) {
        print('$msg:${(msg as ConfotorErrorMsg).error}');
      } else if (msg is CheckInListScanBarcodeMsg) {
        CheckInListItem.fetch(msg.barcode).then((item) {
          this.appState.bus.add(UpdateConferenceMsg(checkInListItem: item));
        }).catchError((e) {
          this.appState.bus.add(ConferencesError(error: e));
        });
        print('Scan BarCode: ${msg.barcode}');
      } else if (msg is UpdateConferenceMsg ||
          msg is RemoveConferences ||
          msg is TicketsPageMsg ||
          msg is CheckInItemCompleteMsg ||
          msg is RefreshConferences) {
        if (msg is RefreshConferences) {
          msg.items.forEach((key) => _conferences.refresh(key));
        } else if (msg is UpdateConferenceMsg) {
          this._conferences.forEach((msg) {
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
        } else if (msg is RemoveConferences) {
          msg.items.forEach((item) {
            this.appState.bus.add(ConferenceRemoved(item: _conferences.remove(item.url)));
          });
        }
        print('CheckItemLists:${this.checkInLists.length}');
        writeLists(this.checkInLists)
            .then((lists) => this
                .appState
                .bus
                .add(new ConferenceMsg(lists: lists), persist: true))
            .catchError((e) {
          print('WTF2:$e');
          this.appState.bus.add(new CheckInListItemError(error: e));
        });
      }
    });
    readConferences().then((lists) {
      lists.forEach((i) => this.appState.bus.add(i));
    }).catchError((e) {
      this.appState.bus.add(new CheckInListItemError(error: e));
    });
  }
}
