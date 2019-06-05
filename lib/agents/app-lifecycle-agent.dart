import 'package:mobx/mobx.dart';

import 'package:flutter/material.dart';


class AppLifecycleAgent with WidgetsBindingObserver, Store {
  final Observable<AppLifecycleState> state = Observable(AppLifecycleState.inactive);
  final WidgetsBinding binding = WidgetsBinding.instance;
  final List<void a(AppLifecycleState state)> actions = [];


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Action(() {
      this.state.value = state;
    })();
  }

  void action(void a(AppLifecycleState state)) {
    actions.add(a);
    
  }

  AppLifecycleAgent start() {
    binding.addObserver(this);
    return this;
  }

  void stop() {
    binding.removeObserver(this);
  }

}