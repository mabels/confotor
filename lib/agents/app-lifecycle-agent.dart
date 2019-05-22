import 'package:confotor/msgs/msgs.dart';

import '../components/confotor-app.dart';
import 'package:flutter/material.dart';


class AppLifecycleAgent with WidgetsBindingObserver {
  final ConfotorAppState appState;
  final WidgetsBinding binding = WidgetsBinding.instance;

  AppLifecycleAgent({ConfotorAppState appState}): appState = appState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("AppLifeCycleAgent:state:$state");
    appState.bus.add(AppLifecycleMsg(state: state));
  }

  AppLifecycleAgent start() {
    binding.addObserver(this);
    return this;
  }

  void stop() {
    binding.removeObserver(this);
  }

}