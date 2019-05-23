
import 'package:meta/meta.dart';

class ConfotorMsg {}

abstract class ConfotorErrorMsg {
  final dynamic error;
  ConfotorErrorMsg({@required dynamic error}): error = error;
}

abstract class ConfotorTransactionMsg {
  final String transaction;
  ConfotorTransactionMsg({transaction}): transaction = transaction;
}