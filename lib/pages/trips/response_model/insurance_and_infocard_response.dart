class TripInsuranceInfocardResponse {
  InsuranceAndInfoCard? insuranceAndInfoCard;
  Status? status;

  TripInsuranceInfocardResponse({this.insuranceAndInfoCard, this.status});

  TripInsuranceInfocardResponse.fromJson(Map<String, dynamic> json) {
    insuranceAndInfoCard = json['InsuranceAndInfoCard'] != null
        ? new InsuranceAndInfoCard.fromJson(json['InsuranceAndInfoCard'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.insuranceAndInfoCard != null) {
      data['InsuranceAndInfoCard'] = this.insuranceAndInfoCard!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class InsuranceAndInfoCard {
  String? iD;
  String? insuranceDocumentID;
  String? infoCardDocumentID;

  InsuranceAndInfoCard(
      {this.iD, this.insuranceDocumentID, this.infoCardDocumentID});

  InsuranceAndInfoCard.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    insuranceDocumentID = json['InsuranceDocumentID'];
    infoCardDocumentID = json['InfoCardDocumentID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['InsuranceDocumentID'] = this.insuranceDocumentID;
    data['InfoCardDocumentID'] = this.infoCardDocumentID;
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