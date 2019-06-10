// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conference.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$Conference on ConferenceBase, Store {
  Computed<dynamic> _$checkInItemLengthComputed;

  @override
  dynamic get checkInItemLength => (_$checkInItemLengthComputed ??=
          Computed<dynamic>(() => super.checkInItemLength))
      .value;
  Computed<Iterable<TicketAndCheckIns>> _$ticketAndCheckInsListComputed;

  @override
  Iterable<TicketAndCheckIns> get ticketAndCheckInsList =>
      (_$ticketAndCheckInsListComputed ??=
              Computed<Iterable<TicketAndCheckIns>>(
                  () => super.ticketAndCheckInsList))
          .value;
  Computed<dynamic> _$ticketAndCheckInsLengthComputed;

  @override
  dynamic get ticketAndCheckInsLength => (_$ticketAndCheckInsLengthComputed ??=
          Computed<dynamic>(() => super.ticketAndCheckInsLength))
      .value;
  Computed<dynamic> _$urlComputed;

  @override
  dynamic get url =>
      (_$urlComputed ??= Computed<dynamic>(() => super.url)).value;
  Computed<dynamic> _$errorComputed;

  @override
  dynamic get error =>
      (_$errorComputed ??= Computed<dynamic>(() => super.error)).value;

  final _$ConferenceBaseActionController =
      ActionController(name: 'ConferenceBase');

  @override
  void updateCheckInItems(
      String transaction, Iterable<CheckInItem> checkInItems) {
    final _$actionInfo = _$ConferenceBaseActionController.startAction();
    try {
      return super.updateCheckInItems(transaction, checkInItems);
    } finally {
      _$ConferenceBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTickets(String transaction, Iterable<Ticket> tickets) {
    final _$actionInfo = _$ConferenceBaseActionController.startAction();
    try {
      return super.updateTickets(transaction, tickets);
    } finally {
      _$ConferenceBaseActionController.endAction(_$actionInfo);
    }
  }
}
