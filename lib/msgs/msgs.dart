import 'dart:convert';
import 'dart:ui';
// import 'package:reflectable/reflectable.dart';

import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/conferences.dart';
import 'package:confotor/models/ticket-and-checkins.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/confotor-msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

// class CheckInItemCompleteMsg extends ConfotorMsg implements ConfotorTransactionMsg {
//   @override
//   final String transaction;
//   final ConferenceKey conference;
//   CheckInItemCompleteMsg({@required ConferenceKey conference, @required String transaction}):
//     conference = conference, transaction = transaction;
// }

// class CheckInItemPageMsg extends ConfotorMsg implements ConfotorTransactionMsg {
//   @override
//   final String transaction;
//   final ConferenceKey conference;
//   final List<CheckInItem> items;
//   CheckInItemPageMsg({
//     @required ConferenceKey conference,
//     @required List<CheckInItem> items,
//     String transaction}):
//     conference = conference, items = items, transaction = transaction;

// }

class RequestLastFoundTickets extends ConfotorMsg {}

class TicketError extends ConfotorMsg
    implements ConfotorErrorMsg, ConfotorTransactionMsg {
  @override
  final String transaction;
  final ConferenceKey conference;
  final dynamic error;
  TicketError(
      {@required dynamic error,
      @required ConferenceKey conference,
      String transaction})
      : error = error,
        conference = conference,
        transaction = transaction;
}

class CheckInItemPageError extends TicketError {
  CheckInItemPageError(
      {@required dynamic error,
      @required ConferenceKey conference,
      String transaction})
      : super(error: error, conference: conference, transaction: transaction);
}

class CheckInObserverError extends ConfotorMsg
    implements ConfotorErrorMsg, ConfotorTransactionMsg {
  @override
  final String transaction;
  final ConferenceKey conference;
  final dynamic error;
  CheckInObserverError(
      {@required dynamic error,
      @required ConferenceKey conference,
      String transaction})
      : error = error,
        conference = conference,
        transaction = transaction;
}

class AppLifecycleMsg extends ConfotorMsg {
  final AppLifecycleState state;
  AppLifecycleMsg({@required AppLifecycleState state}) : state = state;
}

class ConferencesMsg extends ConfotorMsg {
  final Conferences conferences;
  ConferencesMsg({@required Conferences conferences})
      : conferences = conferences;
}

class ConferenceMsg extends ConfotorMsg {
  final Conference conference;
  ConferenceMsg({@required Conference conference}) : conference = conference;
}

class ConferencesError extends ConfotorMsg implements ConfotorErrorMsg {
  final dynamic error;
  ConferencesError({@required error}) : error = error;
}

// class TicketsMsg {
//   final TicketsStatus status;
//   final int page;
//   final int totalTickets;
//   TicketsMsg({@required TicketsStatus status, @required int page, @required int totalTickets}):
//     status = status,
//     page = page,
//     totalTickets = totalTickets;
// }

// class TicketsCompleteMsg extends ConfotorMsg {
//   TicketsCompleteMsg(
//       {CheckInListItem checkInListItem, Map<int, Ticket> tickets, String url})
//       : checkInListItem = checkInListItem,
//         tickets = tickets,
//         url = url;
// }

class PageMsg<T> extends ConfotorMsg {
  final String transaction;
  final CheckInList checkInList;
  final List<T> items;
  final int page;
  final bool completed;
  PageMsg(
      {@required final String transaction,
      @required final CheckInList checkInList,
      @required final List<T> items,
      @required final int page,
      @required final bool completed})
      : transaction = transaction,
        checkInList = checkInList,
        items = items,
        page = page,
        completed = completed;
}

class TicketPageMsg extends PageMsg<Ticket> {
  TicketPageMsg(
      {@required final String transaction,
      @required final CheckInList checkInList,
      @required final List<Ticket> items,
      @required final int page,
      @required final bool completed})
      : super(
            transaction: transaction,
            checkInList: checkInList,
            items: items,
            page: page,
            completed: completed);
}

class CheckInItemPageMsg extends PageMsg<CheckInItem> {
  CheckInItemPageMsg(
      {@required final String transaction,
      @required final CheckInList checkInList,
      @required final List<CheckInItem> items,
      @required final int page,
      @required final bool completed})
      : super(
            transaction: transaction,
            checkInList: checkInList,
            items: items,
            page: page,
            completed: completed);
}

class CheckInActionPageMsg extends PageMsg<CheckInAction> {
  CheckInActionPageMsg(
      {@required final String transaction,
      @required final CheckInList checkInList,
      @required final List<CheckInAction> items,
      @required final int page,
      @required final bool completed})
      : super(
            transaction: transaction,
            checkInList: checkInList,
            items: items,
            page: page,
            completed: completed);
}

class TicketsError extends ConfotorMsg
    implements ConfotorErrorMsg, ConfotorTransactionMsg {
  @override
  final String transaction;
  final String url;
  final ConferenceKey conference;
  final http.Response response;
  final dynamic error;
  TicketsError(
      {@required String url,
      @required ConferenceKey conference,
      http.Response response,
      @required dynamic error,
      @required String transaction})
      : url = url,
        conference = conference,
        response = response,
        error = error,
        transaction = transaction;
}

// class UpdateConferenceMsg extends ConfotorMsg {
//   final ConferenceKey checkInListItem;
//   UpdateConferenceMsg({@required checkInListItem}) :
//     checkInListItem = checkInListItem;
// }

class ConferenceKeysMsg extends ConfotorMsg {
  final List<ConferenceKey> conferenceKeys;
  ConferenceKeysMsg({@required List<ConferenceKey> conferenceKeys})
      : conferenceKeys = conferenceKeys;
}

class CheckInListItemError extends ConferencesMsg implements ConfotorErrorMsg {
  final dynamic error;
  CheckInListItemError({@required dynamic error}) : error = error;
}

// class CheckInListScanMsg extends ConfotorMsg {}

// class CheckInListScanBarcodeMsg extends CheckInListScanMsg {
//   final String barcode;
//   CheckInListScanBarcodeMsg({@required String barcode}) : barcode = barcode;
// }
// class TicketListScanPlatformExceptionMsg extends TicketListScanMsg {
//   final PlatformException exception;
//   TicketListScanPlatformExceptionMsg({PlatformException exception}): exception = exception;
// }

// class TicketListScanFormatExceptionMsg extends TicketListScanMsg {
//   final FormatException exception;
//   TicketListScanFormatExceptionMsg({FormatException exception}): exception = exception;
// }

// class CheckInListScanUnknownExceptionMsg extends CheckInListScanMsg {
//   final dynamic exception;
//   CheckInListScanUnknownExceptionMsg({dynamic exception})
//       : exception = exception;
//}

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
  AddCheckInAction({@required CheckInAction item}) : item = item;
}

// class FindTicket extends ConfotorMsg {
//   final String slug;
//   FindTicket({@required String slug}): slug = slug;
//}

class TicketAction {
  final String type;
  TicketAction(String type) : type = type;

  static Map<Type, Function> registered = Map(); 

  static TicketAction fromJson(dynamic json) {
    switch (json['type']) {
      case "BarcodeScannedTicketAction":
        return BarcodeScannedTicketAction.fromJson(json);
      case "CheckInTransactionTicketAction":
        return CheckInTransactionTicketAction.fromJson(json);
      case "CheckOutTransactionTicketAction":
        return CheckOutTransactionTicketAction.fromJson(json);
      default:
        return TicketAction(json['type']);
    }
    // return ta.fromJson(json);
  }

  @mustCallSuper
  Map<String, dynamic> toJson() => {
    "type": type.toString()
  };
}

class BarcodeScannedTicketAction extends TicketAction {
  final String barcode;
  BarcodeScannedTicketAction({@required barcode})
      : barcode = barcode,
        super("BarcodeScannedTicketAction");

  static BarcodeScannedTicketAction fromJson(dynamic json) {
    return BarcodeScannedTicketAction(barcode: json['barcode']);
  } 

  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "barcode": barcode,
  };

}
// registerTicketAction(type: BarcodeScannedTicketAction, fromJson);

enum CheckInOutTransactionTicketActionStep { Started, Completed, Error }
String asStringCheckInOutTransactionTicketActionStep(CheckInOutTransactionTicketActionStep step) {
  switch (step) {
    case CheckInOutTransactionTicketActionStep.Started: return "Started";
    case CheckInOutTransactionTicketActionStep.Completed: return "Completed";
    case CheckInOutTransactionTicketActionStep.Error:
    default:
      return "Error";
  }
}

CheckInOutTransactionTicketActionStep fromStringCheckInOutTransactionTicketActionStep(String step) {
  switch (step) {
    case "Started": return CheckInOutTransactionTicketActionStep.Started;
    case "Completed": return CheckInOutTransactionTicketActionStep.Completed;
    case "Error": 
    default:
      return CheckInOutTransactionTicketActionStep.Error;
  }
}

class StepTransactionTicketAction extends TicketAction {
  CheckInOutTransactionTicketActionStep step;
  Response res;
  dynamic error;
  StepTransactionTicketAction({@required CheckInOutTransactionTicketActionStep step,
                               @required String type}): 
    step = step, super(type); 

  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "step": asStringCheckInOutTransactionTicketActionStep(step),
    "error": error.toString(),
    "res": res.toString(),
  };
}

class CheckInTransactionTicketAction extends StepTransactionTicketAction {

  CheckInTransactionTicketAction({@required step}):
    super(type: "CheckInTransactionTicketAction", step: step);

  static CheckInTransactionTicketAction fromJson(dynamic json) {
    return CheckInTransactionTicketAction(step: fromStringCheckInOutTransactionTicketActionStep(json['step']));
  } 

  Future<dynamic> run({
    @required String url,
    @required int ticketId
  }) {
    return http.post(url, headers: {
              "Accept": "application/json",
              "Content-Type": "application/json"
            },
            body: json.encode({
              "checkin": {"ticket_id": ticketId}
            }))
        .then((res) {
      step = CheckInOutTransactionTicketActionStep.Completed;
      this.res = res;
    }).catchError((e) {
      step = CheckInOutTransactionTicketActionStep.Error;
      this.error = error;
    });
  }
}

class CheckOutTransactionTicketAction extends StepTransactionTicketAction {
  final String uuid;
  CheckOutTransactionTicketAction({@required step, @required String uuid})
      : uuid = uuid,
        super(type: "CheckOutTransactionTicketAction", step: step);

  Future<dynamic> run({
    @required String url,
  }) {
    return http.delete(url).then((res) {
      step = CheckInOutTransactionTicketActionStep.Completed;
      this.res = res;
    }).catchError((e) {
      step = CheckInOutTransactionTicketActionStep.Error;
      this.error = error;
    });
  }

  static CheckOutTransactionTicketAction fromJson(dynamic json) {
    return CheckOutTransactionTicketAction(
      uuid: json['uuid'],
      step: fromStringCheckInOutTransactionTicketActionStep(json['step']));
  } 

  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    "uuid": uuid
  };
}

class ConferenceTicket extends ConfotorMsg {
  final CheckInList checkInList;
  final TicketAndCheckIns ticketAndCheckIns;
  final List<TicketAction> actions;
  // TicketAndCheckInsState state = TicketAndCheckInsState.Error;

  ConferenceTicket(
      {@required CheckInList checkInList,
      @required TicketAndCheckIns ticketAndCheckIns,
      @required List<TicketAction> actions})
      : checkInList = checkInList,
        ticketAndCheckIns = ticketAndCheckIns,
        actions = actions;


  static _actionsFromJson(dynamic actions) {
    final List<TicketAction> my = [];
    if (actions is List) {
      actions.forEach((ajson) => my.add(TicketAction.fromJson(ajson)));
    }
    return my;
  }

  static ConferenceTicket fromJson(dynamic json) {
    return ConferenceTicket(
        checkInList: CheckInList.fromJson(json['checkInList']),
        ticketAndCheckIns:
            TicketAndCheckIns.fromJson(json['ticketAndCheckIns']),
        actions: _actionsFromJson(json['actions']));
  }

  Map<String, dynamic> toJson() => {
    "checkInList": checkInList,
    "ticketAndCheckIns": ticketAndCheckIns,
    "actions": actions
  };

  bool get issuedFromMe {
    final action = actions.reversed.firstWhere((action) {
      return action is CheckInTransactionTicketAction ||
             action is CheckOutTransactionTicketAction;
    }, orElse: () => null);
    return action is CheckInTransactionTicketAction && 
           action.step == CheckInOutTransactionTicketActionStep.Completed;
  }

  bool get runningAction {
    return actions.firstWhere((action) {
      if (action is CheckInTransactionTicketAction ||
          action is CheckOutTransactionTicketAction) {
            final StepTransactionTicketAction my  = action;
            return !(my.step == CheckInOutTransactionTicketActionStep.Completed ||
                     my.step == CheckInOutTransactionTicketActionStep.Error);
          }
      return false;
    }, orElse: () => null) != null;
  }



  TicketAndCheckInsState get state {
    // ticketAndCheckIns.checkInItems.forEach((ci) => print('cii:${ticketAndCheckIns.ticket.reference}:${json.encode(ci)}'));
    final open = ticketAndCheckIns.checkInItems.firstWhere((i) => i.deleted_at == null, orElse: () => null);
    if (open != null) {
      return TicketAndCheckInsState.Used;
    }
    return TicketAndCheckInsState.Issueable;
  }

  String get shortState => state.toString().split(".").last;

}

class RequestCheckOutTicket extends ConfotorMsg {
  final ConferenceTicket conferenceTicket;
  RequestCheckOutTicket({@required ticket}) : conferenceTicket = ticket;
}

class RequestCheckInTicket extends ConfotorMsg {
  final ConferenceTicket conferenceTicket;
  RequestCheckInTicket({@required ticket}) : conferenceTicket = ticket;
}

abstract class FileName {
  final String fileName;
  FileName(this.fileName);
}

class FileError extends ConfotorMsg implements ConfotorErrorMsg, FileName {
  final dynamic error;
  final String fileName;
  FileError({@required dynamic error, String fileName})
      : error = error,
        fileName = fileName;
}

class JsonObject extends ConfotorMsg implements FileName {
  final dynamic json;
  final String fileName;
  JsonObject({@required dynamic json, String fileName})
      : json = json,
        fileName = fileName;
}

class JsonObjectError extends FileError {
  final String str;
  JsonObjectError(
      {@required dynamic error, String fileName, @required String str})
      : str = str,
        super(error: error, fileName: fileName);
}
