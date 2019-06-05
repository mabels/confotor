import 'dart:convert';

import 'package:confotor/models/ticket.dart';
import 'package:meta/meta.dart';

import 'package:test_api/test_api.dart';

Ticket testTicket({int ticketId}) {
  if (ticketId == null) {
    ticketId = 4811;
  }
  return Ticket(
    id: ticketId,
    slug: 'slug$ticketId',
    firstName: 'firstName',
    lastName: 'lastName',
    email: 'email',
    companyName: 'companyName',
    reference: 'reference',
    registrationReference: 'registrationReference',
    createdAt: 'createdAt',
    updatedAt: 'updatedAt',
  );
}

void main() {
  test('Serialize', () {
    final ticket = testTicket();
    final str = json.encode(ticket);
    final refTicket = Ticket.fromJson(json.decode(str));
    expect(ticket.id, refTicket.id);
    expect(ticket.slug, refTicket.slug);
    expect(ticket.firstName, refTicket.firstName);
    expect(ticket.lastName, refTicket.lastName);
    expect(ticket.email, refTicket.email);
    expect(ticket.companyName, refTicket.companyName);
    expect(ticket.reference, refTicket.reference);
    expect(ticket.registrationReference, refTicket.registrationReference);
    expect(ticket.createdAt, refTicket.createdAt);
    expect(ticket.updatedAt, refTicket.updatedAt);
  });
}
