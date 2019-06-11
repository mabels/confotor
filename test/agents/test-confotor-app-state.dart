import 'package:confotor/agents/app-lifecycle-agent.dart';
import 'package:confotor/agents/conferences-agent.dart';
import 'package:confotor/confotor-appstate.dart';

class TestConfotorAppState with ConfotorAppState {
  start() {
    appLifecycleAgent = AppLifecycleAgent().start();
    conferencesAgent = ConferencesAgent(appState: this).start();
    return this;
  }
}