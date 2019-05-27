import 'package:confotor/actions/scan-action.dart';
import 'package:confotor/components/qr-scan.dart';
import 'package:confotor/components/ticket-list-area.dart';
import 'package:confotor/msgs/scan-msg.dart';
import 'package:flutter/material.dart';
import './confotor-app.dart';
// import 'active-area.dart';
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
  bool toggleQrScan = false;

  ConfotorMainScreenState({@required ConfotorAppState appState})
      : appState = appState;

  _scanAction(int id) {
    if (!toggleQrScan) {
      appState.bus.add(RequestQrScanMsg());
      setState(() => toggleQrScan = true);
    } else {
      appState.bus.add(StopQrScanMsg());
      setState(() => toggleQrScan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Confotor', style: TextStyle(color: Color(0xf3ecda))),
          backgroundColor: Color(0x303f62),
          iconTheme: IconThemeData(color: Color(0xf3ecda))),
      drawer: ConfotorDrawer(appState: appState),
      body: Stack(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                  //height: MediaQuery.of(context).size.height - (60 + 100),
                  color: Color(0x303f62),
                  child: toggleQrScan
                      ? QrScan(appState: appState)
                      : TicketListArea(appState: appState))),
          // Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Container(
          //         height: 100.0,
          //         color: Colors.green[50],
          //         child: LogListArea(appState: appState))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0x303f62),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.business, color: Color(0xf3ecda)),
              title: Text("${toggleQrScan ? 'Scan Off' : 'Scan On'}",
                  style: TextStyle(color: Color(0xf3ecda))),
              backgroundColor: Colors.deepOrange,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school, color: Color(0xf3ecda)),
              title: Text('Add CheckInList',
                  style: TextStyle(color: Color(0xf3ecda))),
              backgroundColor: Colors.deepOrange,
            ),
          ],
          // currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange,
          type: BottomNavigationBarType.fixed,
          onTap: _scanAction),
    );
  }
}
