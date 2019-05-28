import 'dart:async';

import 'package:confotor/components/confotor-app.dart';
import 'package:meta/meta.dart';

class CheckInManager {
  final ConfotorAppState appState;
  StreamSubscription subscription;

  CheckInManager({@required ConfotorAppState appState})
      : appState = appState;

  stop() {
    subscription.cancel();
  }

  start() {
    subscription = this.appState.bus.stream.listen((msg) {
      // Ticket State Motion:
      // Issuable -> RequestCheckIn -> ResponseCheckIn 
      // Issed
    });
  }
}