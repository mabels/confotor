import 'dart:async';
import 'dart:ui';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:confotor/stores/last-found-tickets-store.dart';
import 'package:meta/meta.dart';

class CheckInManager {
  final ConfotorAppState appState;
  StreamSubscription subscription;
  final LastFoundTicketsStore _lastFoundTicketsStore;
  LastFoundTickets jsonLastFoundTicketsStore;

  CheckInManager({@required ConfotorAppState appState})
      : appState = appState,
        _lastFoundTicketsStore = LastFoundTicketsStore(appState: appState);

  stop() {
    subscription.cancel();
  }

  start() {
    subscription = this.appState.bus.stream.listen((msg) {
      if (msg is AppLifecycleMsg) {
        switch (msg.state) {
          // case AppLifecycleState.inactive:
          case AppLifecycleState.suspending:
          case AppLifecycleState.paused:
            _lastFoundTicketsStore.write();
            break;
          case AppLifecycleState.resumed:
            _lastFoundTicketsStore.read();
            break;
          case AppLifecycleState.inactive:
            break;
        }
      }
      if (msg is ResetLastFoundTickets) {
        appState.bus.add(_lastFoundTicketsStore.reset().toLastFoundTickets());
      }
      if (msg is JsonObject) {
        if (msg.json['lastFoundTickets'] != null) {
          jsonLastFoundTicketsStore = LastFoundTickets.fromJson(msg.json['lastFoundTickets']);
          // jsonLastFoundTicketsStore.last.map((i) => i.conferenceTickets.)
          // appState.bus.add(RequestUpdateConference(checkInList: jsonLastFoundTicketsStore.))
        }
      }

      if (msg is ConferencesMsg) {
        _lastFoundTicketsStore.updateFromConferences(msg.conferences);
        if (jsonLastFoundTicketsStore != null) {
          msg.conferences.conferences.forEach((cf) {
            jsonLastFoundTicketsStore.last.reversed.toList().forEach((ft) {
              final cts = Map.fromEntries(ft.conferenceTickets
                        .where((ct) => ct.checkInList.url == cf.checkInList.url)
                        .map((ct) => MapEntry(ct.ticketAndCheckIns.ticket.id, ct)));
              cf.ticketAndCheckInsList.forEach((tac) {
                if (cts.containsKey(tac.ticket.id)) {
                  _lastFoundTicketsStore.updateFoundTickets(ft);
                  jsonLastFoundTicketsStore.last.removeWhere((i) => i.containsSlug(ft));
                }
              });
            });
          });
          if (jsonLastFoundTicketsStore.last.isEmpty) {
            print('lastFoundTicketCompleted');
            jsonLastFoundTicketsStore = null;
          }
        }
        appState.bus.add(_lastFoundTicketsStore.toLastFoundTickets());
      }

      if (msg is RequestCheckInTicket) {
        print('RequestCheckInTicket:${msg.conferenceTicket.checkInList.event_title}:${msg.conferenceTicket.ticketAndCheckIns.ticket.email}');
        _lastFoundTicketsStore.doCheckIn(msg.conferenceTicket); 
      }

      if (msg is RequestCheckOutTicket) {
        print('RequestCheckOutTicket:${msg.conferenceTicket.checkInList.event_title}:${msg.conferenceTicket.ticketAndCheckIns.ticket.email}');
        _lastFoundTicketsStore.doCheckOut(msg.conferenceTicket); 
      }

      if (msg is FoundTickets) {
        appState.bus.add(_lastFoundTicketsStore
            .updateFoundTickets(msg)
            .toLastFoundTickets());
        msg.conferenceTickets.forEach((ct) {
          if (ct.state == TicketAndCheckInsState.Issueable) {
            appState.bus.add(RequestCheckInTicket(ticket: ct));
          }
        });
      }

      if (msg is RequestLastFoundTickets) {
        appState.bus.add(_lastFoundTicketsStore.toLastFoundTickets());
      }

      // Ticket State Motion:
      // Issuable -> RequestCheckIn -> ResponseCheckIn
      // Issed
    });
    _lastFoundTicketsStore.read();
  }
}
