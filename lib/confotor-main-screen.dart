// import 'dart:async';
// import 'dart:convert' as convert;

import 'package:confotor/confotor-drawer.dart';
import 'package:confotor/ticket-list-area.dart';
import 'package:confotor/tickets.dart';
import 'package:flutter/material.dart';
import './check-in-list.dart';
import './confotor-app.dart';
import './ticket.dart';
// import './/check-in-list.dart';
//import './/scan.dart';
//import './/generate.dart';
//import 'package:flutter/rendering.dart';

import 'active-area.dart';
import 'confotor-msg.dart';
// import 'scan.dart';

// Stream<ConfotorMsg> confotorStream(BuildContext context) {
//   // int count = 0;
//   var streamController = new StreamController<ConfotorMsg>();
//   var ticketListAgent = new TicketListAgent(streamController);
//   ticketListAgent.start(context);
//   // var tickets = Tickets.create(id: "wech");
//   // tickets.streamController.stream.listen((msg) {
//   //   streamController.add(msg);
//   // });
//   // src = new StreamController(onListen: () {
//   //   new Timer.periodic(oneSec, (Timer t) {
//   //     print("Jo:${count}:${to}");
//   //     src.add(++count);
//   //     if (count > to) {
//   //       t.cancel();
//   //       src.close();
//   //     }
//   //   });
//   // });
//   return streamController.stream;
// }



logArea({ConfotorAppState appState}) {
  return StreamBuilder(
      stream: appState.bus.stream,
      builder: (BuildContext context, AsyncSnapshot<ConfotorMsg> snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[Text(snapshot.data.runtimeType.toString())],
        );
      });
}

class ConfotorMainScreen extends StatelessWidget {
  final ConfotorAppState appState;

  const ConfotorMainScreen({ConfotorAppState appState}) : appState = appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Confotor'),
        ),
        drawer: ConfotorDrawer(appState: appState),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120.0,
              color: Colors.blue[50],
              alignment: Alignment.topCenter,
              child: ActionArea(appState: appState)
              ),
            Container(
              height: 120.0,
              color: Colors.red[50],
              alignment: Alignment.topCenter,
              child: TicketListArea(appState: appState)
            ),
            Container(
              height: 120.0,
              color: Colors.green[50],
              alignment: Alignment.bottomCenter,
              child: logArea(appState: appState)
            ),
            /*
                actionArea(appState: appState),
                ticketListArea(appState: appState),
                logArea(appState: appState),
                */
          ],
        ));
  }
}

// body: Center(
//     child:
//       Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               child: RaisedButton(
//                   color: Colors.blue,
//                   textColor: Colors.white,
//                   splashColor: Colors.blueGrey,
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => ScanScreen()),
//                     );
//                   },
//                   child: const Text('SCAN QR CODE')
//               ),
//             ),
//            Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               child: RaisedButton(
//                   color: Colors.blue,
//                   textColor: Colors.white,
//                   splashColor: Colors.blueGrey,
//                   onPressed: () {
//                     Navigator.push( //                       context, //                       MaterialPageRoute(builder: (context) => GenerateScreen()),
//                     );
//                   },
//                   child: const Text('GENERATE QR CODE')
//               ),
//             ),
//         ],
//       )
//   ),

// if (snapshot.data is TicketListMsg) {
//   final ticketListMsg = snapshot.data as TicketListMsg;
//   if (ticketListMsg.lists.isEmpty) {
//     return Text('We do not have any TicketList');
//   } else {
//     return Column(
//         children: new List<int>.generate(
//                 ticketListMsg.lists.length, (int i) => i)
//             .map<Widget>((i) {
//       return Container(
//           height: 20,
//           color: Colors.amber[600],
//           key: Key('$i'),
//           child: Text(
//               'TicketList: ${i} ${ticketListMsg.lists[i]}'));
//     }).toList());
//   }
// }
// return Column(
//     // padding: const EdgeInsets.all(8.0),
//     children: new List<int>.generate(1, (int i) => i)
//         .map<Widget>((i) {
//   return Container(
//       height: 20,
//       color: Colors.amber[600],
//       key: Key('$i'),
//       // child: Text('TicketsMsg $i ${snapshot.data.status} ${snapshot.data.page} ${snapshot.data.totalTickets}'));
//       child: Text('unknown'));
// }).toList());
//   case ConnectionState.done:
//     if (snapshot.hasError)
//       return Text('Error: ${snapshot.error}');
//     return Text('Result: ${snapshot.data}');
// }
// return null; // unreachabl
