class VerifyPhoneResponse {
  PhoneVerification? phoneVerification;
  Status? status;

  VerifyPhoneResponse({this.phoneVerification, this.status});

  VerifyPhoneResponse.fromJson(Map<String, dynamic> json) {
    phoneVerification = json['PhoneVerification'] != null
        ? new PhoneVerification.fromJson(json['PhoneVerification'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.phoneVerification != null) {
      data['PhoneVerification'] = this.phoneVerification!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class PhoneVerification {
  String? profileID;
  String? phoneNumber;
  String? code;
  String? dateTime;
  String? verificationStatus;

  PhoneVerification(
      {this.profileID,
        this.phoneNumber,
        this.code,
        this.dateTime,
        this.verificationStatus});

  PhoneVerification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    phoneNumber = json['PhoneNumber'];
    code = json['Code'];
    dateTime = json['DateTime'];
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['PhoneNumber'] = this.phoneNumber;
    data['Code'] = this.code;
    data['DateTime'] = this.dateTime;
    data['VerificationStatus'] = this.verificationStatus;
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