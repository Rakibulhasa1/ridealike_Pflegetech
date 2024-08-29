class SocialLogInResponse {
  User? user;
  String? jWT;
  Status? status;

  SocialLogInResponse({this.user, this.jWT, this.status});

  SocialLogInResponse.fromJson(Map<String, dynamic> json) {
    user = json['User'] != null ? new User.fromJson(json['User']) : null;
    jWT = json['JWT'];
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
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

  User(
      {this.firstName,
        this.lastName,
        this.email,
        this.password,
        this.userID,
        this.profileID,
        this.roles});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['FirstName'];
    lastName = json['LastName'];
    email = json['Email'];
    password = json['Password'];
    userID = json['UserID'];
    profileID = json['ProfileID'];
    roles = json['Roles'].cast<String>();
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