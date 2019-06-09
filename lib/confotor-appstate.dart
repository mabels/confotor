import 'package:confotor/confotor-bus.dart';
import 'package:uuid/uuid.dart';

import 'agents/app-lifecycle-agent.dart';
import 'agents/check-in-list-agent.dart';
import 'agents/check-in-manager.dart';
import 'agents/conferences-agent.dart';
import 'agents/tickets-agent.dart';
import 'models/lane.dart';

abstract class ConfotorAppState {
  final Uuid uuid = Uuid();
  final ConfotorBus bus = ConfotorBus();
  AppLifecycleAgent appLifecycleAgent;
  ConferencesAgent conferencesAgent;
  TicketsAgent ticketsAgent;
  CheckInListAgent checkInListAgent;
  CheckInManager checkInManager;
  Lane lane;
}