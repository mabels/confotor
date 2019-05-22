import 'package:meta/meta.dart';

import 'confotor-msg.dart';

class ScanTicketMsg extends ConfotorMsg {
  final String barcode;
  ScanTicketMsg({@required String barcode}) : barcode = barcode;
}

class ScanTicketErrorMsg extends ConfotorMsg implements ConfotorErrorMsg {
  final dynamic error;
  ScanTicketErrorMsg({@required dynamic error}) : error = error;
}

class ScanCheckInListMsg extends ConfotorMsg {
  final String barcode;
  ScanCheckInListMsg({@required String barcode}) : barcode = barcode;
}

class ScanCheckInListErrorMsg extends ConfotorMsg implements ConfotorErrorMsg {
  final dynamic error;
  ScanCheckInListErrorMsg({@required dynamic error}) : error = error;
}
