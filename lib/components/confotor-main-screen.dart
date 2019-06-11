import 'package:confotor/components/qr-scan.dart';
import 'package:confotor/components/ticket-list-area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../confotor-appstate.dart';
import 'confotor-drawer.dart';

class ConfotorMainScreen extends StatefulWidget {
  final ConfotorAppState appState;
  ConfotorMainScreen({@required appState}) : appState = appState;

  @override
  ConfotorMainScreenState createState() =>
      ConfotorMainScreenState(appState: appState);
}

class ConfotorMainScreenState extends State<ConfotorMainScreen> {
  final ConfotorAppState appState;
  final Observable<bool> _toggleQrScan = Observable(false);

  ConfotorMainScreenState({@required ConfotorAppState appState})
      : appState = appState;

  @override
  void initState() {
    super.initState();
    // appState.bus.listen((msg) {
    //   if (msg is LastFoundTickets || msg is RequestUpdateConference) {
    //     print('LastFoundTickets:toggleQrScan:$msg');
    //     appState.bus.add(StopQrScanMsg());
    //     setState(Action(() => _toggleQrScan.value = false));
    //   }
    // });
  }

  _scanAction() {
    if (!_toggleQrScan.value) {
      // appState.bus.add(RequestQrScanMsg());
      setState(Action(() => _toggleQrScan.value = true));
    } else {
      // appState.bus.add(StopQrScanMsg());
      setState(Action(() => _toggleQrScan.value = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Confotor', style: TextStyle(color: Color(0xFFf3ecda))),
          backgroundColor: Color(0xFF303f62),
          iconTheme: IconThemeData(color: Color(0xFFf3ecda))),
      drawer: ConfotorDrawer(appState: appState),
      body: Stack(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                  //height: MediaQuery.of(context).size.height - (60 + 100),
                  color: Color(0xff303f62),
                  child: Observer(builder: (_) =>
                      _toggleQrScan.value
                       ? QrScan(appState: appState)
                       : TicketListArea(appState: appState)))),
          // Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Container(
          //         height: 100.0,
          //         color: Colors.green[50],
          //         child: LogListArea(appState: appState))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanAction,
        icon: Observer(builder: (_) => Icon(_toggleQrScan.value ? Icons.list : Icons.camera)),
        label: Observer(builder: (_) => Text("${_toggleQrScan.value ? 'Ticket List' : 'Scan On'}",
            style: TextStyle(color: Color(0xFFf3ecda))),
      )),
      // bottomNavigationBar: BottomNavigationBar(
      //     backgroundColor: Color(0xff303f62),
      //     items: <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.business, color: Color(0xFFf3ecda)),
      //         title: Text("${toggleQrScan ? 'Scan Off' : 'Scan On'}",
      //             style: TextStyle(color: Color(0xFFf3ecda))),
      //         backgroundColor: Colors.deepOrange,
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.school, color: Color(0xFFf3ecda)),
      //         title: Text('Add CheckInList',
      //             style: TextStyle(color: Color(0xFFf3ecda))),
      //         backgroundColor: Colors.deepOrange,
      //       ),
      //     ],
      //     // currentIndex: _selectedIndex,
      //     selectedItemColor: Colors.orange,
      //     type: BottomNavigationBarType.fixed,
      //     onTap: _scanAction),
    );
  }
}
