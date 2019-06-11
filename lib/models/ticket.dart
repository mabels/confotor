import 'package:meta/meta.dart';

class Ticket {
  final int id;
  final String slug;
  final String reference;
  final String registrationReference;
  final String createdAt;
  String firstName;
  String lastName;
  String email;
  String companyName;
  String updatedAt;

  static Ticket fromJson(dynamic json) {
    return Ticket(
        id: json['id'],
        slug: json['slug'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        companyName: json['company_name'],
        reference: json['reference'],
        registrationReference: json['registration_reference'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at']);
  }

  static Ticket clone(Ticket oth) {
    return Ticket(
        id: oth.id,
        slug: oth.slug,
        reference: oth.reference,
        registrationReference: oth.registrationReference,
        createdAt: oth.createdAt,
        firstName: oth.firstName,
        lastName: oth.lastName,
        email: oth.email,
        companyName: oth.companyName,
        updatedAt: oth.updatedAt);
  }

  Ticket(
      {@required int id,
      @required String slug,
      @required String reference,
      @required String registrationReference,
      @required String createdAt,
      String firstName,
      String lastName,
      String email,
      String companyName,
      String updatedAt})
      : id = id,
        slug = slug,
        reference = reference,
        registrationReference = registrationReference,
        createdAt = createdAt,
        firstName = firstName,
        lastName = lastName,
        email = email,
        companyName = companyName,
        updatedAt = updatedAt;

  Ticket update(Ticket ticket) {
    firstName = this.firstName;
    lastName = this.lastName;
    email = this.email;
    companyName = this.companyName;
    updatedAt = this.updatedAt;
    return this;
  }

  @override
  bool operator ==(o) {
    return o is Ticket &&
        o.id == id &&
        o.slug == slug &&
        o.reference == reference &&
        o.registrationReference == registrationReference &&
        o.createdAt == createdAt &&
        o.firstName == firstName &&
        o.lastName == lastName &&
        o.email == email &&
        o.companyName == companyName &&
        o.updatedAt == updatedAt;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "company_name": companyName,
        "reference": reference,
        "registration_reference": registrationReference,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
