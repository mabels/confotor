
import 'package:barcode_scan/barcode_scan.dart';
import 'package:confotor/msgs/scan-msg.dart';

import '../confotor-bus.dart';

scanTicketAction({ConfotorBus bus}) {
  BarcodeScanner.scan().then((barcode) {
    bus.add(new ScanTicketMsg(barcode: barcode));
  }).catchError((e) {
    bus.add(new ScanTicketErrorMsg(error: e));
  });
}