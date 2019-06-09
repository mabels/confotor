// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket-observer.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$TicketObserver on TicketObserverBase, Store {
  final _$statusAtom = Atom(name: 'TicketObserverBase.status');

  @override
  TicketsStatus get status {
    _$statusAtom.reportObserved();
    return super.status;
  }

  @override
  set status(TicketsStatus value) {
    _$statusAtom.context.checkIfStateModificationsAreAllowed(_$statusAtom);
    super.status = value;
    _$statusAtom.reportChanged();
  }

  final _$errorAtom = Atom(name: 'TicketObserverBase.error');

  @override
  dynamic get error {
    _$errorAtom.reportObserved();
    return super.error;
  }

  @override
  set error(dynamic value) {
    _$errorAtom.context.checkIfStateModificationsAreAllowed(_$errorAtom);
    super.error = value;
    _$errorAtom.reportChanged();
  }

  final _$responseAtom = Atom(name: 'TicketObserverBase.response');

  @override
  Response get response {
    _$responseAtom.reportObserved();
    return super.response;
  }

  @override
  set response(Response value) {
    _$responseAtom.context.checkIfStateModificationsAreAllowed(_$responseAtom);
    super.response = value;
    _$responseAtom.reportChanged();
  }

  final _$TicketObserverBaseActionController =
      ActionController(name: 'TicketObserverBase');

  @override
  dynamic _thenResponse(String transaction, int page, Response response) {
    final _$actionInfo = _$TicketObserverBaseActionController.startAction();
    try {
      return super._thenResponse(transaction, page, response);
    } finally {
      _$TicketObserverBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic getPages(int page, String transaction) {
    final _$actionInfo = _$TicketObserverBaseActionController.startAction();
    try {
      return super.getPages(page, transaction);
    } finally {
      _$TicketObserverBaseActionController.endAction(_$actionInfo);
    }
  }
}
