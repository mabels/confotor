import 'package:confotor/agents/app-lifecycle-agent.dart';
import 'package:confotor/agents/conferences-agent.dart';
import 'package:confotor/confotor-appstate.dart';
import 'package:flutter/src/widgets/framework.dart';

class TestConfotorAppState extends ConfotorAppState {
  start() {
    appLifecycleAgent = AppLifecycleAgent().start();
    conferencesAgent = ConferencesAgent(appState: this).start();
    return this;
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }
}