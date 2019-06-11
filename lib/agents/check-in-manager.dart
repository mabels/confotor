import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/found-tickets.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/msgs/msgs.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';

class CheckInManager {
  final ConfotorAppState _appState;
  // StreamSubscription subscription;
  final LastFoundTickets _lastFoundTickets;
  LastFoundTickets jsonLastFoundTicketsStore;
  ReactionDisposer appLifecycleDisposer;

  CheckInManager({@required ConfotorAppState appState})
      : _appState = appState,
        _lastFoundTickets = LastFoundTickets();

  stop() {
    // subscription.cancel();
    appLifecycleDisposer();

  }

  start() {
    appLifecycleDisposer = reaction<AppLifecycleState>((_) {
      return _appState.appLifecycleAgent.state.value;
    },
      (state) {
        switch (state) {
          case AppLifecycleState.suspending:
          case AppLifecycleState.paused:
            _lastFoundTickets.write();
            break;
          case AppLifecycleState.resumed:
            _lastFoundTickets.read();
            break;
          case AppLifecycleState.inactive:
            break;
        }
      });


      if (msg is ResetLastFoundTickets) {
        _appState.bus.add(_lastFoundTickets.reset().toLastFoundTickets());
      }
      if (msg is JsonObject) {
        if (msg.json['lastFoundTickets'] != null) {
          jsonLastFoundTicketsStore =
              LastFoundTickets.fromJson(msg.json['lastFoundTickets']);
          // jsonLastFoundTicketsStore.last.map((i) => i.conferenceTickets.)
          // appState.bus.add(RequestUpdateConference(checkInList: jsonLastFoundTicketsStore.))
        }
      }

      if (msg is ConferencesMsg) {
        _lastFoundTickets.updateFromConferences(msg.conferences);
        if (jsonLastFoundTicketsStore != null) {
          msg.conferences.conferences.forEach((cf) {
            jsonLastFoundTicketsStore.values.reversed.toList().forEach((ft) {
              final cts = Map.fromEntries(ft.conferenceTickets
                  .where((ct) => ct.checkInList.url == cf.checkInList.url)
                  .map((ct) => MapEntry(ct.ticketAndCheckIns.ticket.id, ct)));
              cf.ticketAndCheckInsList.forEach((tac) {
                if (cts.containsKey(tac.ticket.id)) {
                  _lastFoundTickets.updateFoundTickets(ft);
                  jsonLastFoundTicketsStore.values
                      .removeWhere((i) => i.containsSlug(ft));
                }
              });
            });
          });
          if (jsonLastFoundTicketsStore.values.isEmpty) {
            print('lastFoundTicketCompleted');
            jsonLastFoundTicketsStore = null;
          }
        }
        _appState.bus.add(_lastFoundTickets.toLastFoundTickets());
      }

      if (msg is RequestCheckInTicket) {
        print(
            'RequestCheckInTicket:${msg.conferenceTicket.checkInList.eventTitle}:${msg.conferenceTicket.ticketAndCheckIns.ticket.email}');
        _lastFoundTickets.doCheckIn(msg.conferenceTicket);
      }

      if (msg is RequestCheckOutTicket) {
        print(
            'RequestCheckOutTicket:${msg.conferenceTicket.checkInList.eventTitle}:${msg.conferenceTicket.ticketAndCheckIns.ticket.email}');
        _lastFoundTickets.doCheckOut(msg.conferenceTicket);
      }

      if (msg is FoundTickets) {
        _appState.bus.add(_lastFoundTickets
            .updateFoundTickets(msg)
            .toLastFoundTickets());
        if (msg.unambiguous && msg.isInTicketLane) {
          msg.conferenceTickets.forEach((ct) {
            if (ct.state == TicketAndCheckInsState.Issueable) {
              _appState.bus.add(RequestCheckInTicket(ticket: ct));
            }
          });
        }
      }

      if (msg is RequestLastFoundTickets) {
        _appState.bus.add(_lastFoundTickets.toLastFoundTickets());
      }

      // Ticket State Motion:
      // Issuable -> RequestCheckIn -> ResponseCheckIn
      // Issed
    });
    _lastFoundTicketsStore.read();
  }
}
