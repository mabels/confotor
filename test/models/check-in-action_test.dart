
import 'dart:convert';

import 'package:confotor/models/check-in-action.dart';
import 'package:test_api/test_api.dart';


void main() {
  test('Serialize', () {
    final cia = CheckInAction(id: 'x', ticketId:  5);
    final str = json.encode(cia);
    final refCia = CheckInAction.fromJson(json.decode(str));
    expect(cia.id, refCia.id);
    expect(cia.ticketId, refCia.ticketId);
  });
}
