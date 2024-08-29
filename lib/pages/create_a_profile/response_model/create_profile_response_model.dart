class CreateProfileResponse {
  User? user;
  String? jWT;
  Status? status;
  String? error;
  int? code;
  String? message;
  List<Details>? details;

  CreateProfileResponse({this.user, this.jWT, this.status,this.error, this.code, this.message, this.details});

  CreateProfileResponse.fromJson(Map<String, dynamic> json) {
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    jWT = json['JWT'];
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
    error = json['error'];
    code = json['code'];
    message = json['message'];
    if (json['details'] != null) {
      details =  <Details>[];
      json['details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['User'] = this.user!.toJson();
    }
    data['JWT'] = this.jWT;
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    data['error'] = this.error;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? userID;
  String? profileID;
  List<String>? roles;
  RegistrationStatus? registrationStatus;
   String? phoneNumber ;

  User(
      {this.firstName,
        this.lastName,
        this.email,
        this.password,
        this.userID,
        this.profileID,
        this.roles,
        this.registrationStatus});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['FirstName'];
    lastName = json['LastName'];
    email = json['Email'];
    password = json['Password'];
    userID = json['UserID'];
    profileID = json['ProfileID'];
    roles = json['Roles'].cast<String>();
    registrationStatus = json['RegistrationStatus'] != null
        ? new RegistrationStatus.fromJson(json['RegistrationStatus'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Email'] = this.email;
    data['Password'] = this.password;
    data['UserID'] = this.userID;
    data['ProfileID'] = this.profileID;
    data['Roles'] = this.roles;
    if (this.registrationStatus != null) {
      data['RegistrationStatus'] = this.registrationStatus!.toJson();
    }
    return data;
  }
}

class RegistrationStatus {
  bool? phoneVerified;
  bool? termsAndConditionAccepted;
  bool? dLVerified;
  bool? emailVerified;
  bool? dLDocumentsSubmitted;

  RegistrationStatus(
      {this.phoneVerified,
        this.termsAndConditionAccepted,
        this.dLVerified,
        this.emailVerified,
        this.dLDocumentsSubmitted});

  RegistrationStatus.fromJson(Map<String, dynamic> json) {
    phoneVerified = json['PhoneVerified'];
    termsAndConditionAccepted = json['TermsAndConditionAccepted'];
    dLVerified = json['DLVerified'];
    emailVerified = json['EmailVerified'];
    dLDocumentsSubmitted = json['DLDocumentsSubmitted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PhoneVerified'] = this.phoneVerified;
    data['TermsAndConditionAccepted'] = this.termsAndConditionAccepted;
    data['DLVerified'] = this.dLVerified;
    data['EmailVerified'] = this.emailVerified;
    data['DLDocumentsSubmitted'] = this.dLDocumentsSubmitted;
    return data;
  }
}

class Status {
  bool? success;
  String? error;

  Status({this.success, this.error});

  Status.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    return data;
  }
}

class Details {
  String? typeUrl;
  String? value;

  Details({this.typeUrl, this.value});

  Details.fromJson(Map<String, dynamic> json) {
    typeUrl = json['@type'];
    value = json['Email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@type'] = this.typeUrl;
    data['Email'] = this.value;
    return data;
  }
}