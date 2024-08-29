class ProfileVerificationResponse {
  Verification? verification;
  Status? status;

  ProfileVerificationResponse({this.verification, this.status});

  ProfileVerificationResponse.fromJson(Map<String, dynamic> json) {
    verification = json['Verification'] != null
        ? new Verification.fromJson(json['Verification'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.verification != null) {
      data['Verification'] = this.verification!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class Verification {
  String? profileID;
  String? userID;
  PhoneVerification? phoneVerification;
  EmailVerification? emailVerification;
  IdentityVerification? identityVerification;
  TermsAndConditionAccept? termsAndConditionAccept;
  TermsAndConditionAccept? promotionalUpdatesAccept;
  DLVerification? dLVerification;
  EmailVerification? drivingRecordVerification;
  String? verificationStatus;

  Verification(
      {this.profileID,
        this.userID,
        this.phoneVerification,
        this.emailVerification,
        this.identityVerification,
        this.termsAndConditionAccept,
        this.promotionalUpdatesAccept,
        this.dLVerification,
        this.drivingRecordVerification,
        this.verificationStatus});

  Verification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    userID = json['UserID'];
    phoneVerification = json['PhoneVerification'] != null
        ? new PhoneVerification.fromJson(json['PhoneVerification'])
        : null;
    emailVerification = json['EmailVerification'] != null
        ? new EmailVerification.fromJson(json['EmailVerification'])
        : null;
    identityVerification = json['IdentityVerification'] != null
        ? new IdentityVerification.fromJson(json['IdentityVerification'])
        : null;
    termsAndConditionAccept = json['TermsAndConditionAccept'] != null
        ? new TermsAndConditionAccept.fromJson(json['TermsAndConditionAccept'])
        : null;
    promotionalUpdatesAccept = json['PromotionalUpdatesAccept'] != null
        ? new TermsAndConditionAccept.fromJson(json['PromotionalUpdatesAccept'])
        : null;
    dLVerification = json['DLVerification'] != null
        ? new DLVerification.fromJson(json['DLVerification'])
        : null;
    drivingRecordVerification = json['DrivingRecordVerification'] != null
        ? new EmailVerification.fromJson(json['DrivingRecordVerification'])
        : null;
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['UserID'] = this.userID;
    if (this.phoneVerification != null) {
      data['PhoneVerification'] = this.phoneVerification!.toJson();
    }
    if (this.emailVerification != null) {
      data['EmailVerification'] = this.emailVerification!.toJson();
    }
    if (this.identityVerification != null) {
      data['IdentityVerification'] = this.identityVerification!.toJson();
    }
    if (this.termsAndConditionAccept != null) {
      data['TermsAndConditionAccept'] = this.termsAndConditionAccept!.toJson();
    }
    if (this.promotionalUpdatesAccept != null) {
      data['PromotionalUpdatesAccept'] = this.promotionalUpdatesAccept!.toJson();
    }
    if (this.dLVerification != null) {
      data['DLVerification'] = this.dLVerification!.toJson();
    }
    if (this.drivingRecordVerification != null) {
      data['DrivingRecordVerification'] =
          this.drivingRecordVerification!.toJson();
    }
    data['VerificationStatus'] = this.verificationStatus;
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

class EmailVerification {
  String? profileID;
  String? dateTime;
  String? verificationStatus;

  EmailVerification({this.profileID, this.dateTime, this.verificationStatus});

  EmailVerification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    dateTime = json['DateTime'];
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['DateTime'] = this.dateTime;
    data['VerificationStatus'] = this.verificationStatus;
    return data;
  }
}

class IdentityVerification {
  String? profileID;
  String? imageID;
  String? dateTime;
  String? verificationStatus;

  IdentityVerification(
      {this.profileID, this.imageID, this.dateTime, this.verificationStatus});

  IdentityVerification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    imageID = json['ImageID'];
    dateTime = json['DateTime'];
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['ImageID'] = this.imageID;
    data['DateTime'] = this.dateTime;
    data['VerificationStatus'] = this.verificationStatus;
    return data;
  }
}

class TermsAndConditionAccept {
  String? profileID;
  bool?accept;
  String? dateTime;
  String? verificationStatus;

  TermsAndConditionAccept(
      {this.profileID, this.accept, this.dateTime, this.verificationStatus});

  TermsAndConditionAccept.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    accept = json['Accept'];
    dateTime = json['DateTime'];
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['Accept'] = this.accept;
    data['DateTime'] = this.dateTime;
    data['VerificationStatus'] = this.verificationStatus;
    return data;
  }
}

class DLVerification {
  String? profileID;
  DLFrontVerification? dLFrontVerification;
  DLBackVerification? dLBackVerification;
  String? verificationStatus;

  DLVerification(
      {this.profileID,
        this.dLFrontVerification,
        this.dLBackVerification,
        this.verificationStatus});

  DLVerification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    dLFrontVerification = json['DLFrontVerification'] != null
        ? new DLFrontVerification.fromJson(json['DLFrontVerification'])
        : null;
    dLBackVerification = json['DLBackVerification'] != null
        ? new DLBackVerification.fromJson(json['DLBackVerification'])
        : null;
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    if (this.dLFrontVerification != null) {
      data['DLFrontVerification'] = this.dLFrontVerification!.toJson();
    }
    if (this.dLBackVerification != null) {
      data['DLBackVerification'] = this.dLBackVerification!.toJson();
    }
    data['VerificationStatus'] = this.verificationStatus;
    return data;
  }
}

class DLFrontVerification {
  String? profileID;
  String? dLFrontImageID;
  String? dLFrontDateTime;
  String? verificationStatus;

  DLFrontVerification(
      {this.profileID,
        this.dLFrontImageID,
        this.dLFrontDateTime,
        this.verificationStatus});

  DLFrontVerification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    dLFrontImageID = json['DLFrontImageID'];
    dLFrontDateTime = json['DLFrontDateTime'];
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['DLFrontImageID'] = this.dLFrontImageID;
    data['DLFrontDateTime'] = this.dLFrontDateTime;
    data['VerificationStatus'] = this.verificationStatus;
    return data;
  }
}

class DLBackVerification {
  String? profileID;
  String? dLBackImageID;
  String? dLBackDateTime;
  String? verificationStatus;

  DLBackVerification(
      {this.profileID,
        this.dLBackImageID,
        this.dLBackDateTime,
        this.verificationStatus});

  DLBackVerification.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    dLBackImageID = json['DLBackImageID'];
    dLBackDateTime = json['DLBackDateTime'];
    verificationStatus = json['VerificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['DLBackImageID'] = this.dLBackImageID;
    data['DLBackDateTime'] = this.dLBackDateTime;
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