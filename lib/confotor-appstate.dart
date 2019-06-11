import 'package:confotor/agents/check-in-items-agent.dart';
import 'package:confotor/confotor-bus.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'agents/app-lifecycle-agent.dart';
import 'agents/check-in-manager.dart';
import 'agents/conferences-agent.dart';
import 'agents/tickets-agent.dart';
import 'components/confotor-app.dart';
import 'models/lane.dart';

part 'confotor-appstate.g.dart';

abstract class ConfotorAppState extends ConfotorAppStateBase with _$ConfotorAppState {
}

abstract class ConfotorAppStateBase extends State<ConfotorApp> with Store {
  final Uuid uuid = Uuid();
  final ConfotorBus bus = ConfotorBus();
  final Iterable<Lane> lanes = [
    Lane('a-c'),
    Lane('d-h'),
    Lane('i-k'),
    Lane('l-m'),
    Lane('n-r'),
    Lane('s-z')
  ];
  AppLifecycleAgent appLifecycleAgent;
  ConferencesAgent conferencesAgent;
  TicketsAgent ticketsAgent;
  CheckInItemsAgent checkInItemsAgent;
  CheckInManager checkInManager;
  @observable
  Lane lane;

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}