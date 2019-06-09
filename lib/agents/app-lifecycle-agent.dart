import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

import 'package:flutter/material.dart';

part 'app-lifecycle-agent.g.dart';

class AppLifecycleAgent extends AppLifecycleAgentBase with _$AppLifecycleAgent {
}

class My extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state) _func;

  My(void func(AppLifecycleState state)): _func = func;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _func(state);
  }

}

abstract class AppLifecycleAgentBase with Store {
  Observable<AppLifecycleState> _state = Observable(AppLifecycleState.inactive);
  final WidgetsBinding _binding = WidgetsBinding.instance;
  My _my;

  AppLifecycleAgentBase() {
    _my = My((state) => this.state = state);
  }

  @computed
  get state => _state.value;

  @action
  set state(AppLifecycleState state) => _state.value = state;


  AppLifecycleAgent start() {
    if (_binding != null) { // tests
      _binding.addObserver(_my);
    }
    return this;
  }

  void stop() {
    if (_binding != null) { // tests
      _binding.removeObserver(_my);
    }
  }

}