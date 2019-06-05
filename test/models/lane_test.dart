
import 'dart:convert';

import 'package:confotor/models/lane.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('Order', () {
    final my = Lane('a-z');
    expect(my.start, 'A');
    expect(my.end, 'Z');
  });

  test('UnOrder', () {
    final my = Lane('z-a');
    expect(my.start, 'A');
    expect(my.end, 'Z');
  });

    test('Null', () {
    final my = Lane(null);
    expect(my.start, null);
    expect(my.end, null);
  });

  test('Serialization', () {
    final my = Lane('a-z');
    final str = json.encode(my);
    final mjs = json.decode(str);
    expect(mjs, 'A-Z');
    final ref = Lane.fromJson(mjs);
    expect(my.start, ref.start);
    expect(my.end, ref.end);
  });

  test('Serialization null', () {
    final my = Lane(null);
    final str = json.encode(my);
    final mjs = json.decode(str);
    expect(mjs, null);
    final ref = Lane.fromJson(mjs);
    expect(my.start, ref.start);
    expect(my.end, ref.end);
  });


}