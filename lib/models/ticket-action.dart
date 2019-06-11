import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import 'fix-http-client.dart';
import 'lane.dart';

class TicketAction {
  final String type;
  TicketAction(String type) : type = type;

  static final Map<Type, Function> registered = Map();

  static TicketAction fromJson(dynamic json) {
    if (!(json['type'] is String)) {
      throw Exception("unkown type");
    }
    switch (json['type']) {
      case "BarcodeScannedTicketAction":
        return BarcodeScannedTicketAction.fromJson(json);
      case "CheckInTransactionTicketAction":
        return CheckInTransactionTicketAction.fromJson(json);
      case "CheckOutTransactionTicketAction":
        return CheckOutTransactionTicketAction.fromJson(json);
      case "AmbiguousAction":
        return AmbiguousAction.fromJson(json);
      default:
        throw Exception("unkown type: ${json['type']}");
    }
    // return ta.fromJson(json);
  }

  @override
  bool operator ==(o) => o is TicketAction && o.type == type;

  Map<String, dynamic> toJson() => {"type": type.toString()};

}

class AmbiguousAction extends TicketAction {
  final String barcode;
  AmbiguousAction({@required barcode})
      : barcode = barcode,
        super("AmbiguousAction");

  static AmbiguousAction fromJson(dynamic json) {
    return AmbiguousAction(barcode: json['barcode']);
  }

  @override
  bool operator ==(o) {
    return o is AmbiguousAction && o.barcode == barcode && super==o;
  }

  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "barcode": barcode,
      };
}

class BarcodeScannedTicketAction extends TicketAction {
  final String barcode;
  final Lane lane;

  BarcodeScannedTicketAction({@required String barcode, @required Lane lane})
      : barcode = barcode,
        lane = lane,
        super("BarcodeScannedTicketAction");

  @override
  bool operator ==(o) {
    return o is BarcodeScannedTicketAction && o.barcode == barcode && o.lane == lane && super==o;
  } 

  static BarcodeScannedTicketAction fromJson(dynamic json) {
    return BarcodeScannedTicketAction(
        barcode: json['barcode'],
        lane: Lane(json['lane']));
  }

  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "barcode": barcode,
        "lane": lane
      };

}
// registerTicketAction(type: BarcodeScannedTicketAction, fromJson);

enum CheckInOutTransactionTicketActionStep { Started, Completed, Error }

String asStringCheckInOutTransactionTicketActionStep(
    CheckInOutTransactionTicketActionStep step) {
  switch (step) {
    case CheckInOutTransactionTicketActionStep.Started:
      return "Started";
    case CheckInOutTransactionTicketActionStep.Completed:
      return "Completed";
    case CheckInOutTransactionTicketActionStep.Error:
    default:
      return "Error";
  }
}

CheckInOutTransactionTicketActionStep
    fromStringCheckInOutTransactionTicketActionStep(String step) {
  switch (step) {
    case "Started":
      return CheckInOutTransactionTicketActionStep.Started;
    case "Completed":
      return CheckInOutTransactionTicketActionStep.Completed;
    case "Error":
    default:
      return CheckInOutTransactionTicketActionStep.Error;
  }
}

abstract class StepTransactionTicketAction extends TicketAction {
  CheckInOutTransactionTicketActionStep step;
  http.Response res;
  dynamic error;

  StepTransactionTicketAction(
      {@required CheckInOutTransactionTicketActionStep step,
      @required String type})
      : step = step,
        super(type);

  @override
  bool operator ==(o) {
    return o is StepTransactionTicketAction && 
           o.step == step &&
           o.res == res &&
           o.error == error &&
           super==o;
  } 

  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        "step": asStringCheckInOutTransactionTicketActionStep(step),
        "error": error.toString(),
        "res": res.toString(),
      };

}

class CheckInTransactionTicketAction extends StepTransactionTicketAction {
  CheckInTransactionTicketAction({@required step})
      : super(type: "CheckInTransactionTicketAction", step: step);

  static CheckInTransactionTicketAction fromJson(dynamic json) {
    return CheckInTransactionTicketAction(
        step: fromStringCheckInOutTransactionTicketActionStep(json['step']));
  }

  @override
  bool operator ==(o) {
    return o is CheckInTransactionTicketAction && super==o;
  } 

  Future<dynamic> run(
      {@required String url, @required int ticketId, BaseClient client }) {
    return fixHttpClient(client)
        .post(url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json"
            },
            body: json.encode({
              "checkin": {"ticket_id": ticketId}
            }))
        .then((res) {
      this.res = res;
      if (200 <= res.statusCode && res.statusCode < 300) {
        step = CheckInOutTransactionTicketActionStep.Completed;
      } else {
        step = CheckInOutTransactionTicketActionStep.Error;
        this.error = Exception('Status Code missmatch:${res.statusCode}');
      }
    }).catchError((e) {
      step = CheckInOutTransactionTicketActionStep.Error;
      this.error = e;
    });
  }

}

class CheckOutTransactionTicketAction extends StepTransactionTicketAction {
  final String uuid;

  CheckOutTransactionTicketAction({@required step, @required String uuid})
      : uuid = uuid,
        super(type: "CheckOutTransactionTicketAction", step: step);

  Future<dynamic> run({@required String url, BaseClient client }) {
    return fixHttpClient(client).delete(url).then((res) {
      if (200 <= res.statusCode && res.statusCode < 300) {
        step = CheckInOutTransactionTicketActionStep.Completed;
        this.res = res;
      } else {
        step = CheckInOutTransactionTicketActionStep.Error;
        this.res = res;
        this.error = Exception('Status Code missmatch');
      }
    }).catchError((e) {
      step = CheckInOutTransactionTicketActionStep.Error;
      this.error = e;
    });
  }

  @override
  bool operator ==(o) {
    return o is CheckOutTransactionTicketAction && o.uuid == uuid && super==o;
  } 

  static CheckOutTransactionTicketAction fromJson(dynamic json) {
    return CheckOutTransactionTicketAction(
        uuid: json['uuid'],
        step: fromStringCheckInOutTransactionTicketActionStep(json['step']));
  }

  Map<String, dynamic> toJson() => {...super.toJson(), "uuid": uuid};

}
