import 'package:confotor/agents/app-lifecycle-agent.dart';
import 'package:confotor/agents/check-in-items-agent.dart';
import 'package:confotor/agents/check-in-manager.dart';
import 'package:confotor/agents/conferences-agent.dart';
import 'package:confotor/agents/tickets-agent.dart';
import 'package:confotor/models/lane.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../confotor-appstate.dart';
// import '../confotor-bus.dart';
import './confotor-main-screen.dart';
// import 'package:uuid/uuid.dart';


// Stream<ConfotorMsg> stream;
//   @override
//   State<StatefulWidget> createState() {
//     this.stream = confotorStream(context);
//     return null;
//   }

class ConfotorApp extends StatefulWidget {
  @override
  ConfotorAppStateImpl createState() => ConfotorAppStateImpl();
}

class ConfotorAppStateImpl extends State<ConfotorApp> with ConfotorAppState {
  // final uuid = Uuid();
  // final ConfotorBus bus = ConfotorBus();
  AppLifecycleAgent appLifecycleAgent;
  ConferencesAgent conferencesAgent;
  TicketsAgent ticketsAgent;
  CheckInItemsAgent checkInItemsAgent;
  CheckInManager checkInManager;
  Lane lane;

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  initState() {
    super.initState();
    this.appLifecycleAgent = AppLifecycleAgent().start();
    this.conferencesAgent = ConferencesAgent(appState: this).start();
    this.ticketsAgent = TicketsAgent(appState: this).start();
    this.checkInItemsAgent = CheckInItemsAgent(appState: this).start();
    // this.checkInManager = CheckInManager(appState: this).start();
  }

  @override
  void dispose() {
    super.dispose();
    this.bus.stop();
    this.appLifecycleAgent.stop();
    this.conferencesAgent.stop();
    this.ticketsAgent.stop();
    this.checkInItemsAgent.stop();
    // this.checkInManager.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Confotor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConfotorMainScreen(appState: this)
    );
  }

}