import 'package:meta/meta.dart';

import 'confotor-msg.dart';

class RequestQrScanMsg extends ConfotorMsg {
}

class StopQrScanMsg extends ConfotorMsg {
}

// class CloseQrScan extends ConfotorMsg {
// }

class QrScanMsg extends ConfotorMsg {
  final String barcode;
  QrScanMsg({@required String barcode}) : barcode = barcode;
}

class QrScanErrorMsg extends ConfotorMsg implements ConfotorErrorMsg {
  final dynamic error;
  QrScanErrorMsg({@required dynamic error}) : error = error;
}

class ScanTicketMsg extends QrScanMsg {
  ScanTicketMsg({@required String barcode}) : super(barcode: barcode);
}

class ScanCheckInListMsg extends QrScanMsg {
  ScanCheckInListMsg({@required String barcode}) : super(barcode: barcode);
}
