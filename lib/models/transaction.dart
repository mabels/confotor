import 'package:meta/meta.dart';

class Transaction<T> {
  String transaction;
  final T value;
  Transaction({
    @required T value,
    String transaction
  }): value = value, transaction = transaction;
}