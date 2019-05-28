
import 'package:barcode_scan/barcode_scan.dart';
import 'package:confotor/msgs/scan-msg.dart';

import '../confotor-bus.dart';

scanAction({ConfotorBus bus}) {
  BarcodeScanner.scan().then((msg) {
    bus.add(QrScanMsg(barcode: msg));
  }).catchError((e) {
    bus.add(QrScanErrorMsg(error: e));
  });
}