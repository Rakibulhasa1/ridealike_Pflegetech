class ReimbursementResponse {
  Reimbursement? reimbursement;
  Status? status;

  ReimbursementResponse({this.reimbursement, this.status});

  ReimbursementResponse.fromJson(Map<String, dynamic> json) {
    reimbursement = json['Reimbursement'] != null
        ? new Reimbursement.fromJson(json['Reimbursement'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.reimbursement != null) {
      data['Reimbursement'] = this.reimbursement!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class Reimbursement {
  String? tripID;
  String? reimbursementDate;
  double? amount;
  String? description;
  List<String>? imageIDs;

  Reimbursement(
      {this.tripID,
        this.amount,
        this.description,
        this.imageIDs});

  Reimbursement.fromJson(Map<String, dynamic> json) {
    tripID = json['TripID'];
    reimbursementDate = json['ReimbursementDate'];
    amount =double.parse( json['Amount'].toString());
    description = json['Description'];
    imageIDs = json['ImageIDs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TripID'] = this.tripID;
    data['ReimbursementDate'] = this.reimbursementDate;
    data['Amount'] = this.amount;
    data['Description'] = this.description;
    data['ImageIDs'] = this.imageIDs;
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
