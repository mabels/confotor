
import 'package:barcode_scan/barcode_scan.dart';

import 'confotor-app.dart';
import 'confotor-msg.dart';



class Ticket {
  int id;
  String slug;
  String first_name;
  String last_name;
  String email;
  String company_name;
  String reference;
  String registration_reference;
  String created_at;
  String updated_at;

  update(Ticket oth) {
    if (id == oth.id && slug == oth.slug && reference == oth.reference
        && registration_reference == oth.registration_reference) {
          throw Exception("try update Ticket does not match");
        }
    first_name = oth.first_name;
    last_name = oth.last_name;
    email = oth.email;
    company_name = oth.company_name;
    created_at = oth.created_at;
    updated_at = oth.updated_at;
  }

  static Ticket create(dynamic json) {
    var ticket = new Ticket();
    ticket.id = json['id'];
    ticket.slug = json['slug'];
    ticket.first_name = json['first_name'];
    ticket.last_name = json['last_name'];
    ticket.email = json['email'];
    ticket.company_name = json['company_name'];
    ticket.reference = json['reference'];
    ticket.registration_reference = json['registration_reference'];
    ticket.created_at = json['created_at'];
    ticket.updated_at = json['updated_at'];
    return ticket;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "first_name": first_name,
    "last_name": last_name,
    "email": email,
    "company_name": company_name,
    "reference": reference,
    "registration_reference": registration_reference,
    "created_at": created_at,
    "updated_at": updated_at,
  };

}

class TicketScanMsg extends ConfotorMsg {}

class TicketScanBarcodeMsg extends TicketScanMsg {
  final String barcode;
  TicketScanBarcodeMsg({String barcode}) : barcode = barcode;
}

class TicketScanUnknownExceptionMsg extends TicketScanMsg {
  final dynamic exception;
  TicketScanUnknownExceptionMsg({dynamic exception})
      : exception = exception;
}

ticketScan({ConfotorBus bus}) {
  BarcodeScanner.scan().then((barcode) {
    bus.add(new TicketScanBarcodeMsg(barcode: barcode));
  }).catchError((e) {
    bus.add(new TicketScanUnknownExceptionMsg(exception: e));
  });
}