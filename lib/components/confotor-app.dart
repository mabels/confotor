import 'package:confotor/agents/app-lifecycle-agent.dart';
import 'package:confotor/agents/check-in-agent.dart';
import 'package:confotor/agents/conferences-agent.dart';
import 'package:confotor/agents/tickets-agent.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../confotor-bus.dart';
import './confotor-main-screen.dart';
import 'package:uuid/uuid.dart';


// Stream<ConfotorMsg> stream;
//   @override
//   State<StatefulWidget> createState() {
//     this.stream = confotorStream(context);
//     return null;
//   }

class ConfotorApp extends StatefulWidget {
  @override
  ConfotorAppState createState() => new ConfotorAppState();
}

class ConfotorAppState extends State<ConfotorApp> {
  final uuid = new Uuid();
  final ConfotorBus bus = new ConfotorBus();
  AppLifecycleAgent appLifecycleAgent;
  ConferencesAgent conferencesAgent;
  TicketsAgent ticketsAgent;
  CheckInAgent checkInAgent;

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  initState() {
    super.initState();

    this.appLifecycleAgent = AppLifecycleAgent(appState: this).start();
    this.conferencesAgent = ConferencesAgent(appState: this).start();
    this.ticketsAgent = TicketsAgent(appState: this).start();
    this.checkInAgent = CheckInAgent(appState: this).start();
  }

  @override
  void dispose() {
    super.dispose();
    this.bus.stop();
    this.appLifecycleAgent.stop();
    this.conferencesAgent.stop();
    // this.ticketsAgent.stop();
    this.checkInAgent.stop();
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