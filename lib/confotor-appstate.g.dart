// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confotor-appstate.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$ConfotorAppState on ConfotorAppStateBase, Store {
  final _$laneAtom = Atom(name: 'ConfotorAppStateBase.lane');

  @override
  Lane get lane {
    _$laneAtom.reportObserved();
    return super.lane;
  }

  @override
  set lane(Lane value) {
    _$laneAtom.context.checkIfStateModificationsAreAllowed(_$laneAtom);
    super.lane = value;
    _$laneAtom.reportChanged();
  }
}
