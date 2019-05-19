// import 'dart:async';
// import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import './check-in-list.dart';
import './confotor-app.dart';
// import './/check-in-list.dart';
//import './/scan.dart';
//import './/generate.dart';
//import 'package:flutter/rendering.dart';

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
        drawer: this.appState.drawer,
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              StreamBuilder(
                stream: this.appState.bus.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<ConfotorMsg> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('Press button to start.');
                    case ConnectionState.waiting:
                      return Text('Waiting.');
                    case ConnectionState.active:
                      if (snapshot.data is CheckInListsMsg) {
                        CheckInListsMsg ret = snapshot.data;
                        if (ret.lists.isEmpty) {
                          return RaisedButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            splashColor: Colors.blueGrey,
                            onPressed: () {
                              checkInListScan(bus: this.appState.bus);
                            },
                            child: Text('Add Check-In List')
                          );
                        }
                        return Column(
                            // padding: const EdgeInsets.all(8.0),
                            children: ret.lists.map<Widget>((i) {
                          // return Container(
                          //     height: 20,
                          //     color: Colors.amber[600],
                          //     key: Key('${i.url}'),
                          //     child: Text('${i.event_title}'));

                          return RaisedButton(
                            color: Colors.amber[600],
                            textColor: Colors.white,
                            splashColor: Colors.blueGrey,
                            onPressed: () {
                              this.appState.bus.add(new CheckInListItemRemove(item: i));
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute(builder: (context) => ScanScreen()),
        //                     );
                            },
                            child: Text('REMOVE:${i.event_title}:${i.tickets.length}')
                          );


                        }).toList());
                      }
                      return Text('Msg: ${snapshot.data}');
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
                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      return Text('Result: ${snapshot.data}');
                  }
                  return null; // unreachable
                },
              )
            ]))
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
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute(builder: (context) => GenerateScreen()),
        //                     );
        //                   },
        //                   child: const Text('GENERATE QR CODE')
        //               ),
        //             ),
        //         ],
        //       )
        //   ),
        );
  }
}
