import 'dart:async';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:confotor/msgs/scan-msg.dart';
import 'package:confotor/stores/conferences-store.dart';
import 'package:meta/meta.dart';

class ConferencesAgent {
  final ConfotorAppState appState;
  final ConferencesStore _conferences;
  StreamSubscription subscription;
  final LastFoundTickets _lastFoundTickets = LastFoundTickets();

  ConferencesAgent({@required ConfotorAppState appState})
      : appState = appState,
        _conferences = ConferencesStore(appState: appState);

  stop() {
    subscription.cancel();
  }

  start() {
    subscription = this.appState.bus.stream.listen((msg) {
      if (msg is JsonObject) {
        final conferences = Conferences.fromJson(msg.json['conferences']);
        conferences.conferences.forEach((conf) => appState.bus.add(
            RequestUpdateConference(
                checkInList: conf.checkInList, conference: conf)));
      } else if (msg is UpdatedConference) {
        print('conferences-agent:UpdateConference:${msg.conference}');
        if (msg.conference != null) {
          if (msg.conference.ticketAndCheckInsList != null) {
            msg.conference.ticketAndCheckInsList.forEach((tac) {
              _conferences.updateTicketPage(TicketPageMsg(
                  transaction: appState.uuid.v4(),
                  checkInList: msg.checkInList,
                  items: msg.conference.ticketAndCheckInsList
                      .map((tac) => tac.ticket),
                  page: 1,
                  completed: true));
              _conferences.updateCheckInItemPage(CheckInItemPageMsg(
                  transaction: appState.uuid.v4(),
                  checkInList: msg.checkInList,
                  items: msg.conference.ticketAndCheckInsList
                      .expand((tac) => tac.checkInItems),
                  page: 1,
                  completed: true));
              _conferences.updateCheckInActionPage(CheckInActionPageMsg(
                  transaction: appState.uuid.v4(),
                  checkInList: msg.checkInList,
                  items: msg.conference.ticketAndCheckInsList
                      .expand((tac) => tac.checkInActions),
                  page: 1,
                  completed: true));
            });
          }
        }
      } else if (msg is RequestUpdateConference) {
        // final ruc = msg as RequestUpdateConference;
        appState.bus.add(UpdatedConference(
            checkInList: _conferences.updateConference(msg).checkInList,
            conference: msg.conference));
        appState.bus.add(_conferences.toConferences());
      } else if (msg is RequestRemoveConference) {
        // final ruc = msg as RequestRemoveConference;
        appState.bus.add(RemovedConference(
            checkInList: _conferences.remove(msg.conference)));
        appState.bus.add(ConferencesMsg(conferences: _conferences.toConferences()));
      } else if (msg is FindTicket) {
        appState.bus.add(_conferences.findTickets(msg.slug));
      }

      if (msg is CheckInItemPageMsg) {
        try {
          // print('UpdateCheckInItem:${msg.items.length}');
          final conference = _conferences.updateCheckInItemPage(msg);
          if (msg.completed && msg.items.isNotEmpty) {
            appState.bus.add(ConferenceMsg(
              conference: conference.toConference())
            );
          }
        } catch (e) {
          appState.bus.add(CheckInItemPageError(
              conference: msg.checkInList,
              transaction: msg.transaction,
              error: e));
        }
      }

      if (msg is TicketPageMsg) {
        try {
          print('UpdateTicket:${msg.items.length}');
          final conference = _conferences.updateTicketPage(msg);
          if (msg.completed) {
            appState.bus.add(ConferenceMsg(
              conference: conference.toConference())
            );
          }
        } catch (e) {
          appState.bus.add(TicketError(
              conference: msg.checkInList,
              transaction: msg.transaction,
              error: e));
        }
      }

      if (msg is ConferenceMsg || msg is RequestConferencesMsg) {
        // print('ConferenceMsg:${msg.conference.url}');
        appState.bus.add(ConferencesMsg(conferences: _conferences.toConferences()));
      }

      if (msg is ScanCheckInListMsg) {
        CheckInList.fetch(msg.barcode).then((item) {
          this.appState.bus.add(RequestUpdateConference(checkInList: item));
        }).catchError((e) {
          this.appState.bus.add(ConferencesError(error: e));
        });
      }

      if (msg is JsonObjectError || msg is FileError) {
        final fileName = msg as FileName;
        _conferences.conferencesFile.then((conferencesFile) {
          print('Run:${fileName.fileName}:${conferencesFile.path}');
          if (fileName.fileName == conferencesFile.path) {
            this.appState.bus.add(ConferencesMsg(conferences: _conferences.toConferences()));
          }
        });
      }

      if (msg is QrScanMsg) {
        CheckInList.fetch(msg.barcode).then((checkInList) {
          // print('CheckInList:then:${msg.barcode}');
          appState.bus.add(RequestUpdateConference(checkInList: checkInList));
        }).catchError((e) {
          final found = _conferences.findTickets(msg.barcode);
          if (found.conferenceTickets.isNotEmpty) {
            // print('CheckInList:exp:${msg.barcode}');
            appState.bus.add(found);
          }
        });
      }

      if (msg is FoundTickets) {
        appState.bus.add(_lastFoundTickets.update(msg));
      }

      if (msg is RequestLastFoundTickets) {
        appState.bus.add(_lastFoundTickets.clone());
      }

      if (msg is ConferencesMsg) {
        _conferences.writeConference();
      }
    });
    /* Boot Application by reading file */
    _conferences.readConferences();
    // appState.bus.add(ConferencesMsg(conferences: Conferences(conferences: [])));
  }
}

//   // print('CheckInList:${msg}');
//   if (msg is CheckInItemMsg) {
//     final idx =
//         this.checkInLists.indexWhere((i) => i.url == msg.listItem.url);
//     if (idx >= 0) {
//       final cil = this.checkInLists[idx];
//       var tac = cil._[msg.item.ticket_id];
//       if (tac == null) {
//         tac = cil._.putIfAbsent(msg.item.ticket_id, () {
//           return TicketAndCheckIns(ticket: null);
//         });
//       }
//       try {
//           // json.encode(msg.item);
//           tac.checkInItems.putIfAbsent(msg.item.uuid, () => CheckInItemAndActions(item: msg.item));
//           tac.checkInItems[msg.item.uuid].item.update(msg.item);
//       } catch (e) {
//         print('EncodingError:${msg.item}:${msg.item.uuid}');
//       }
//     }
//   } else

//   if (msg is ScanTicketMsg) {
//     ScanTicketMsg tsmsg = msg;
//     final found = _conferences.findTickets(tsmsg.barcode);
//     this.appState.bus.add(found);
//     print('TicketScanBarcodeMsg:$found');
//   } else if (msg is ConfotorErrorMsg) {
//     print('$msg:${(msg as ConfotorErrorMsg).error}');
//   } else if (msg is CheckInListScanBarcodeMsg) {
//     CheckInListItem.fetch(msg.barcode).then((item) {
//       this.appState.bus.add(UpdateConferenceMsg(checkInListItem: item));
//     }).catchError((e) {
//       this.appState.bus.add(ConferencesError(error: e));
//     });
//     print('Scan BarCode: ${msg.barcode}');
//   } else if (msg is UpdateConferenceMsg ||
//       msg is RemoveConferences ||
//       msg is TicketsPageMsg ||
//       msg is CheckInItemCompleteMsg ||
//       msg is RefreshConferences) {
//     if (msg is RefreshConferences) {
//       msg.items.forEach((key) => _conferences.refresh(key));
//     } else if (msg is UpdateConferenceMsg) {
//       this._conferences.forEach((msg) {
//         final idx = msg.items.indexWhere((i) => i.url == checkInList.url);
//         if (idx >= 0 || msg.items.isEmpty) {
//           checkInList.ticketsStatus = CheckInListItemTicketsStatus.Initial;
//           checkInList._.clear();
//         }
//       });
//     } else if (msg is TicketsPageMsg) {
//       var tickets = ticketsPageTransactions[msg.transaction];
//       if (tickets == null) {
//         ticketsPageTransactions[msg.transaction] = tickets = new Map();
//       }
//       tickets.addAll(msg.tickets);
//       if (msg.completed) {
//         ticketsPageTransactions.remove(msg.transaction);
//         final idx = this.checkInLists.indexWhere((i) {
//           return i.url == msg.checkInListItem.url;
//         });
//         if (idx >= 0) {
//           this.checkInLists[idx]._.clear();
//           tickets.values.forEach((t) {
//             var tac = this.checkInLists[idx]._[t.id];
//             if (tac == null) {
//               tac = TicketAndCheckIns(ticket: t);
//               this.checkInLists[idx]._[t.id] = tac;
//             }
//             tac.ticket.update(t);
//           });
//           this.checkInLists[idx].ticketsStatus =
//               CheckInListItemTicketsStatus.Fetched;
//         }
//       } else {
//         return; // don't write incomplete
//       }
//     } else if (msg is CheckInListItem) {
//       final idx = this.checkInLists.indexWhere((i) {
//         return i.url == msg.url;
//       });
//       if (idx >= 0) {
//         this.checkInLists[0] = msg;
//       } else {
//         this.checkInLists.add(msg);
//       }
//     } else if (msg is RemoveConferences) {
//       msg.items.forEach((item) {
//         this.appState.bus.add(ConferenceRemoved(item: _conferences.remove(item.url)));
//       });
//     }
//     print('CheckItemLists:${this.checkInLists.length}');
//     writeLists(this.checkInLists)
//         .then((lists) => this
//             .appState
//             .bus
//             .add(new ConferenceMsg(lists: lists), persist: true))
//         .catchError((e) {
//       print('WTF2:$e');
//       this.appState.bus.add(new CheckInListItemError(error: e));
//     });
//   }
