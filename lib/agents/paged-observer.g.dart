// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged-observer.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$PagedObserver on PagedObserverBase, Store {
  final _$statusAtom = Atom(name: 'PagedObserverBase.status');

  @override
  PagedStatus get status {
    _$statusAtom.reportObserved();
    return super.status;
  }

  @override
  set status(PagedStatus value) {
    _$statusAtom.context.checkIfStateModificationsAreAllowed(_$statusAtom);
    super.status = value;
    _$statusAtom.reportChanged();
  }

  final _$errorAtom = Atom(name: 'PagedObserverBase.error');

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

  final _$responseAtom = Atom(name: 'PagedObserverBase.response');

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

  final _$PagedObserverBaseActionController =
      ActionController(name: 'PagedObserverBase');

  @override
  dynamic _thenResponse(PagedAction action, String transaction, int page,
      String url, Response response) {
    final _$actionInfo = _$PagedObserverBaseActionController.startAction();
    try {
      return super._thenResponse(action, transaction, page, url, response);
    } finally {
      _$PagedObserverBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic getPages(PagedAction action, String transaction, int page) {
    final _$actionInfo = _$PagedObserverBaseActionController.startAction();
    try {
      return super.getPages(action, transaction, page);
    } finally {
      _$PagedObserverBaseActionController.endAction(_$actionInfo);
    }
  }
}
