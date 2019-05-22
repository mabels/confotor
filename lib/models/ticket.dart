
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

  static Ticket fromJson(dynamic json) {
    return Ticket().updateFromJson(json);
  }

  updateFromJson(dynamic json) {
    id = json['id'];
    slug = json['slug'];
    first_name = json['first_name'];
    last_name = json['last_name'];
    email = json['email'];
    company_name = json['company_name'];
    reference = json['reference'];
    registration_reference = json['registration_reference'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    return this;
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
