import 'dart:async';

import 'package:confotor/msgs/confotor-msg.dart';
import 'package:confotor/msgs/scan-msg.dart';
import 'package:flutter/material.dart';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:mobx/mobx.dart';

import '../confotor-appstate.dart';
import 'confotor-app.dart';

class RestartQRReaderController extends ConfotorMsg {
  final String id;
  RestartQRReaderController({@required String id}) : id = id;
}

class QrScan extends StatefulWidget {
  final ConfotorAppState _appState;
  QrScan({@required ConfotorAppState appState}) : _appState = appState;

  @override
  State<StatefulWidget> createState() {
    return QrScanState(appState: _appState);
  }
}

class QrScanState extends State<QrScan> {
  final ConfotorAppState _appState;
  final String id;
  QRReaderController controller;
  String lastCode;
  ReactionDisposer _appLicecycleDisposer;
  // StreamSubscription subscription;

  QrScanState({@required ConfotorAppState appState})
      : _appState = appState,
        id = appState.uuid.v4();

  QRReaderController _controller(List<CameraDescription> cameras) {
    controller = QRReaderController(
        cameras[0], ResolutionPreset.low, [CodeFormat.qr, CodeFormat.pdf417],
        (code) async {
      if (lastCode != code) {
        _appState.bus.add(QrScanMsg(barcode: code));
        lastCode = code;
      }
      // if (controller != null) {
      //   await controller.stopScanning();
      // }
      // if (controller != null) {
      //   await controller.startScanning();
      // }
    });
        controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        _appState.bus.add(QrScanErrorMsg(
            error: 'Camera error ${controller.value.errorDescription}'));
      }
    });
    controller.initialize().then((_) {
      if (controller != null) {
        controller.startScanning().then((_) {
          setState(() {});
        });
      }
    });
    return controller;
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      controller = _controller(cameras);
      _appLicecycleDisposer = reaction((_) => _appState.appLifecycleAgent.state,
        (state) {
          switch (state) {
            // case AppLifecycleState.inactive:
            case AppLifecycleState.paused:
              if (controller != null) controller.stopScanning();
              if (controller != null) controller.dispose();
              setState(() {
                controller = null;
              });
              break;
            case AppLifecycleState.suspending:
            case AppLifecycleState.resumed:
              controller = _controller(cameras);
              // _start(cameras);
              break;
            case AppLifecycleState.inactive:
              break;
          }
        });
      // _start(cameras);
    }).catchError((e) {});
  }

  @override
  void dispose() {
    super.dispose();
    _appLicecycleDisposer();
    // if (subscription != null) {
    //   subscription.cancel();
    //   subscription = null;
    // }
    if (controller != null) {
      controller.dispose();
      controller = null;
    }
  }

  // void onNewCameraSelected(CameraDescription cameraDescription) async {
  //   // If the controller is updated then update the UI.
  //   controller.addListener(() {
  //     if (mounted) setState(() {});
  //     if (controller.value.hasError) {
  //       _appState.bus.add(QrScanErrorMsg(
  //           error: 'Camera error ${controller.value.errorDescription}'));
  //     }
  //   });

  //   try {
  //     await controller.initialize();
  //   } on QRReaderException catch (e) {
  //     _appState.bus.add(QrScanErrorMsg(error: e));
  //   }

  //   if (mounted) {
  //     setState(() {});
  //     controller.startScanning();
  //   }
  // }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'No camera selected',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new QRReaderPreview(controller),
      );
    }
  }

  Widget _camera() {
    if (controller == null) {
      return Text("Waiting for CameraController");
    } else if (controller.value.hasError) {
      return Text("Got Camera Error:${controller.value.errorDescription}");
    } else {
      return Padding(
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: _cameraPreviewWidget(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff303f62),
      child: _camera(),
    );
  }
}
