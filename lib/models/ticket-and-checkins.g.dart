// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket-and-checkins.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars

mixin _$TicketAndCheckIns on TicketAndCheckInsBase, Store {
  final _$_ticketAtom = Atom(name: 'TicketAndCheckInsBase._ticket');

  @override
  Ticket get _ticket {
    _$_ticketAtom.reportObserved();
    return super._ticket;
  }

  @override
  set _ticket(Ticket value) {
    _$_ticketAtom.context.checkIfStateModificationsAreAllowed(_$_ticketAtom);
    super._ticket = value;
    _$_ticketAtom.reportChanged();
  }

  final _$TicketAndCheckInsBaseActionController =
      ActionController(name: 'TicketAndCheckInsBase');

  @override
  dynamic updateTicket(Ticket oth) {
    final _$actionInfo = _$TicketAndCheckInsBaseActionController.startAction();
    try {
      return super.updateTicket(oth);
    } finally {
      _$TicketAndCheckInsBaseActionController.endAction(_$actionInfo);
    }
  }
}
