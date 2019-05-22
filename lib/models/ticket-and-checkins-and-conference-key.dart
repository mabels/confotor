import 'package:confotor/models/ticket-and-checkins.dart';

import 'conference.dart';

class TicketAndCheckInsAndConferenceKey {
  final TicketAndCheckIns ticketAndCheckIns;  
  final ConferenceKey conferenceKey;
  TicketAndCheckInsAndConferenceKey({
    TicketAndCheckIns ticketAndCheckIns,  
    ConferenceKey conferenceKey
  }): ticketAndCheckIns = ticketAndCheckIns, conferenceKey = conferenceKey;
}
