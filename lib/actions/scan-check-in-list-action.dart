
import 'package:barcode_scan/barcode_scan.dart';
import 'package:confotor/msgs/scan-msg.dart';

import '../confotor-bus.dart';

scanCheckInListAction({ConfotorBus bus}) {
  BarcodeScanner.scan().then((barcode) {
    bus.add(new ScanCheckInListMsg(barcode: barcode));
  }).catchError((e) {
    bus.add(new ScanCheckInListErrorMsg(error: e));
  });
}
