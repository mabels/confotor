
import 'dart:ui';

import 'package:confotor/agents/tickets-agent.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket-and-checkins-and-conference-key.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;


class CheckInItemCompleteMsg extends ConfotorMsg {
  final CheckInListItem listItem;
  CheckInItemCompleteMsg({CheckInListItem listItem}):
    listItem = listItem;
}
class CheckInItemMsg extends ConfotorMsg {
  final CheckInListItem listItem;
  final CheckInItem item;
  CheckInItemMsg({CheckInListItem listItem, CheckInItem item}):
    listItem = listItem, item = item;
}

class CheckInObserverError extends ConfotorMsg implements ConfotorErrorMsg {
  final CheckInListItem listItem;
  final dynamic error;
  CheckInObserverError({dynamic error, CheckInListItem listItem}):
    error = error, listItem = listItem;
}


class AppLifecycleMsg extends ConfotorMsg {
  final AppLifecycleState state;
  AppLifecycleMsg({@required AppLifecycleState state}): state = state;
}

class ConferencesMsg extends ConfotorMsg {
  final List<Conference> conferences;
  ConferencesMsg({@required conferences}): conferences = conferences;
}

class ConferencesError extends ConfotorMsg implements ConfotorErrorMsg {
  final dynamic error;
  ConferencesError({@required error}): error = error;
}

class TicketsMsg {
  final TicketsStatus status;
  final int page;
  final int totalTickets;
  TicketsMsg({@required TicketsStatus status, @required int page, @required int totalTickets}):
    status = status,
    page = page,
    totalTickets = totalTickets;
}


class FoundTickets extends ConfotorMsg {
  final List<TicketAndCheckInsAndConferenceKey> ticketConferenceKeys;
  FoundTickets({@required ticketConferenceKeys}): ticketConferenceKeys = ticketConferenceKeys;

  get hasFound {
    return ticketConferenceKeys.isNotEmpty;
  }
  get slug {
    return hasFound ? ticketConferenceKeys.first.ticketAndCheckIns.slug : "Not Found";
  }
  get name {
    return hasFound ? "${ticketConferenceKeys.first.ticketAndCheckIns.ticket.first_name} ${ticketConferenceKeys.first.ticketAndCheckIns.ticket.last_name}" : "John Doe";
  }
}

const List<FoundTickets> emptyFoundTickets = [];
class LastFoundTickets extends ConfotorMsg {
  final List<FoundTickets> last;
  LastFoundTickets({List<FoundTickets> last = emptyFoundTickets}): last = List.from(last);
}

// class TicketsCompleteMsg extends ConfotorMsg {
//   TicketsCompleteMsg(
//       {CheckInListItem checkInListItem, Map<int, Ticket> tickets, String url})
//       : checkInListItem = checkInListItem,
//         tickets = tickets,
//         url = url;
// }

class TicketsPageMsg extends ConfotorMsg {
  final String transaction;
  final ConferenceKey conferenceKey;
  final Map<int, Ticket> tickets;
  final int page;
  final bool completed;
  TicketsPageMsg({
    @required final String transaction,
    @required final ConferenceKey conferenceKey,
    @required final Map<int, Ticket> tickets,
    @required final int page,
    @required final bool completed
    }) :
      transaction = transaction,
      conferenceKey = conferenceKey,
      tickets = tickets,
      page = page,
      completed = completed;
}

class TicketsError extends ConfotorMsg with ConfotorErrorMsg {
  final String url;
  final ConferenceKey conferenceKey;
  final http.Response response;
  final dynamic error;
  TicketsError({
      @required String url,
      @required ConferenceKey conferenceKey,
      @required http.Response response,
      @required dynamic error})
      : url = url,
        conferenceKey = conferenceKey,
        response = response,
        error = error;
}


class UpdateConferenceMsg extends ConfotorMsg {
  final CheckInListItem checkInListItem;
  UpdateConferenceMsg({@required checkInListItem}) :
    checkInListItem = checkInListItem;
}

class ConferenceKeysMsg extends ConfotorMsg {
  final List<ConferenceKey> conferenceKeys;
  ConferenceKeysMsg({@required List<ConferenceKey> conferenceKeys}) : conferenceKeys = conferenceKeys;
}

class CheckInListItemError extends ConferencesMsg implements ConfotorErrorMsg {
  final dynamic error;
  CheckInListItemError({@required dynamic error}) : error = error;
}

class RemoveConferences extends ConfotorMsg {
  final List<ConferenceKey> items;
  RemoveConferences({@required List<ConferenceKey> items}) : items = items;
}

class ConferenceRemoved extends ConfotorMsg {
  final Conference item;
  ConferenceRemoved({@required Conference item}) : item = item;
}

const List<ConferenceKey> empty = [];
class RefreshConferences extends ConfotorMsg {
  final List<ConferenceKey> items;
  RefreshConferences({List<ConferenceKey> items: empty}) : items = items;
}

class CheckInListScanMsg extends ConfotorMsg {}

class CheckInListScanBarcodeMsg extends CheckInListScanMsg {
  final String barcode;
  CheckInListScanBarcodeMsg({@required String barcode}) : barcode = barcode;
}
// class TicketListScanPlatformExceptionMsg extends TicketListScanMsg {
//   final PlatformException exception;
//   TicketListScanPlatformExceptionMsg({PlatformException exception}): exception = exception;
// }

// class TicketListScanFormatExceptionMsg extends TicketListScanMsg {
//   final FormatException exception;
//   TicketListScanFormatExceptionMsg({FormatException exception}): exception = exception;
// }

class CheckInListScanUnknownExceptionMsg extends CheckInListScanMsg {
  final dynamic exception;
  CheckInListScanUnknownExceptionMsg({dynamic exception})
      : exception = exception;
}

// class CheckedTicketError extends ConfotorMsg implements ConfotorErrorMsg {
//   final dynamic error;
//   CheckedTicketError({FoundTicket foundTicket, http.Response res, dynamic error}):
//     error = error;
// }


// class CheckedInTicket extends CheckedTicket {
//   final CheckedInResponse checkedIn;

//   CheckedInTicket({FoundTicket foundTicket, http.Response res}):
//     checkedIn = CheckedInResponse.create(res),
//     super(foundTicket: foundTicket, res: res);
// }

class AddCheckInAction extends ConfotorMsg {
  final CheckInAction item;
  AddCheckInAction({@required CheckInAction item}): item = item;
}

class FindTicket extends ConfotorMsg {
  final String slug;
  FindTicket({@required String slug}): slug = slug;
}

class ConferenceTicket extends ConfotorMsg {
  final String slug;
  ConferenceTicket({@required String slug}): slug = slug;

}