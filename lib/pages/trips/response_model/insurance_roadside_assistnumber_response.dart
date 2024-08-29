class InsuranceRoadSideNumbers {
  InsuranceAndRoadSideAssistNumbers? insuranceAndRoadSideAssistNumbers;
  Status? status;

  InsuranceRoadSideNumbers(
      {this.insuranceAndRoadSideAssistNumbers, this.status});

  InsuranceRoadSideNumbers.fromJson(Map<String, dynamic> json) {
    insuranceAndRoadSideAssistNumbers =
    json['InsuranceAndRoadSideAssistNumbers'] != null
        ? new InsuranceAndRoadSideAssistNumbers.fromJson(
        json['InsuranceAndRoadSideAssistNumbers'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.insuranceAndRoadSideAssistNumbers != null) {
      data['InsuranceAndRoadSideAssistNumbers'] =
          this.insuranceAndRoadSideAssistNumbers!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class InsuranceAndRoadSideAssistNumbers {
  String? iD;
  String? insuranceCallNumber;
  String? roadSideAssistNumber;

  InsuranceAndRoadSideAssistNumbers(
      {this.iD, this.insuranceCallNumber, this.roadSideAssistNumber});

  InsuranceAndRoadSideAssistNumbers.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    insuranceCallNumber = json['InsuranceCallNumber'];
    roadSideAssistNumber = json['RoadSideAssistNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['InsuranceCallNumber'] = this.insuranceCallNumber;
    data['RoadSideAssistNumber'] = this.roadSideAssistNumber;
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