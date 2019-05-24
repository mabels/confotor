
import 'package:barcode_scan/barcode_scan.dart';
import 'package:confotor/msgs/scan-msg.dart';

import '../confotor-bus.dart';

scanCheckInListAction({ConfotorBus bus}) {
  BarcodeScanner.scan().then((barcode) {
    bus.add(ScanCheckInListMsg(barcode: barcode));
  }).catchError((e) {
    bus.add(ScanCheckInListErrorMsg(error: e));
  });
}
