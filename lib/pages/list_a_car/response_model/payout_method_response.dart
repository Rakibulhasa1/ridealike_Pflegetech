class FetchPayoutMethodResponse {
  PayoutMethod? payoutMethod;
  Status? status;

  FetchPayoutMethodResponse({this.payoutMethod, this.status});

  FetchPayoutMethodResponse.fromJson(Map<String, dynamic> json) {
    payoutMethod = json['PayoutMethod'] != null
        ? new PayoutMethod.fromJson(json['PayoutMethod'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.payoutMethod != null) {
      data['PayoutMethod'] = this.payoutMethod!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class PayoutMethod {
  String? userID;
  String? payoutMethodType;
  PaypalData? paypalData;
  InteracETransferData? interacETransferData;
  DirectDepositData? directDepositData;

  PayoutMethod(
      {this.userID,
        this.payoutMethodType,
        this.paypalData,
        this.interacETransferData,
        this.directDepositData});

  PayoutMethod.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    payoutMethodType = json['PayoutMethodType'];
    paypalData = json['PaypalData'] != null
        ? new PaypalData.fromJson(json['PaypalData'])
        : null;
    interacETransferData = json['InteracETransferData'] != null
        ? new InteracETransferData.fromJson(json['InteracETransferData'])
        : null;
    directDepositData = json['DirectDepositData'] != null
        ? new DirectDepositData.fromJson(json['DirectDepositData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserID'] = this.userID;
    data['PayoutMethodType'] = this.payoutMethodType;
    if (this.paypalData != null) {
      data['PaypalData'] = this.paypalData!.toJson();
    }
    if (this.interacETransferData != null) {
      data['InteracETransferData'] = this.interacETransferData!.toJson();
    }
    if (this.directDepositData != null) {
      data['DirectDepositData'] = this.directDepositData!.toJson();
    }
    return data;
  }
}

class PaypalData {
  String? email;

  PaypalData({this.email});

  PaypalData.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    return data;
  }
}
class InteracETransferData {
  String? email;

  InteracETransferData({this.email});

  InteracETransferData.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    return data;
  }
}

class DirectDepositData {
  String? address;
  String? city;
  String? province;
  String? postalCode;
  String? country;
  String? name;
  String? iBAN;

  DirectDepositData(
      {this.address,
        this.city,
        this.province,
        this.postalCode,
        this.country,
        this.name,
        this.iBAN});

  DirectDepositData.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    city = json['City'];
    province = json['Province'];
    postalCode = json['PostalCode'];
    country = json['Country'];
    name = json['Name'];
    iBAN = json['IBAN'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    data['City'] = this.city;
    data['Province'] = this.province;
    data['PostalCode'] = this.postalCode;
    data['Country'] = this.country;
    data['Name'] = this.name;
    data['IBAN'] = this.iBAN;
    return data;
  }
}

class Status {
  bool? success;
  String? error;

  Status({this.success, this.error});

  Status.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    error = json['Error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Success'] = this.success;
    data['Error'] = this.error;
    return data;
  }
}
