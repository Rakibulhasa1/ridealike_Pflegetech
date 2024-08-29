class ProfileResponse {
  Profile? profile;
  Status? status;

  ProfileResponse({this.profile, this.status});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    profile =
    json['Profile'] != null ? new Profile.fromJson(json['Profile']) : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profile != null) {
      data['Profile'] = this.profile!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class Profile {
  String? firstName;
  String? lastName;
  String? email;
  String? profileID;
  String? userID;
  String? imageID;
  String? phoneNumber;
  String? verificationStatus;
  String? aboutMe;
  double? profileRating;
  String? createdAt;
  int? numberOfTrips;

  Profile(
      {this.firstName,
        this.lastName,
        this.email,
        this.profileID,
        this.userID,
        this.imageID,
        this.phoneNumber,
        this.verificationStatus,
        this.aboutMe,
        this.profileRating,
        this.createdAt,
        this.numberOfTrips});

  Profile.fromJson(Map<String, dynamic> json) {
    firstName = json['FirstName'];
    lastName = json['LastName'];
    email = json['Email'];
    profileID = json['ProfileID'];
    userID = json['UserID'];
    imageID = json['ImageID'];
    phoneNumber = json['PhoneNumber'];
    verificationStatus = json['VerificationStatus'];
    aboutMe = json['AboutMe'];
    profileRating = double.parse(json['ProfileRating'].toString());
    createdAt = json['CreatedAt'];
    numberOfTrips = json['NumberOfTrips'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Email'] = this.email;
    data['ProfileID'] = this.profileID;
    data['UserID'] = this.userID;
    data['ImageID'] = this.imageID;
    data['PhoneNumber'] = this.phoneNumber;
    data['VerificationStatus'] = this.verificationStatus;
    data['AboutMe'] = this.aboutMe;
    data['ProfileRating'] = this.profileRating;
    data['CreatedAt'] = this.createdAt;
    data['NumberOfTrips'] = this.numberOfTrips;
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
