
class InspectTripEndRentoutResponse {
  TripEndInspectionRentout? tripEndInspectionRentout;
  Status? status;

  InspectTripEndRentoutResponse({this.tripEndInspectionRentout, this.status});

  InspectTripEndRentoutResponse.fromJson(Map<String, dynamic> json) {
    tripEndInspectionRentout = json['TripEndInspectionRentout'] != null
        ? new TripEndInspectionRentout.fromJson(
        json['TripEndInspectionRentout'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tripEndInspectionRentout != null) {
      data['TripEndInspectionRentout'] = this.tripEndInspectionRentout!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class TripEndInspectionRentout {
  bool? isNoticibleDamage;
  List<String>? damageImageIDs;
  List<String>? exteriorImageIDs;
  List<String>? interiorImageIDs;
  List<String>? fuelImageIDs;
  List<String>? mileageImageIDs;
  List<String>? fuelReceiptImageIDs;
  bool? pickUpFee;
  bool? dropOffFee;
  bool? fuelFee;
  bool? kmFee;
  bool? interiorCleanFee;
  bool? exteriorCleanFee;

  String? damageDesctiption;
  String? cleanliness;
  String? exteriorCleanliness;
  String? interiorCleanliness;
  String? fuelLevel;
  int? mileage;

  int? requestedCleaningFee;
  bool? isFuelSameLevelAsBefore;
  int? requestedChargeForFuel;
  bool? isAddedMileageWithinAllocated;
  int? kmOverTheLimit;
  bool? isTicketsTolls;
  TicketsTollsReimbursement? ticketsTollsReimbursement;
  String? tripID;
  String? inspectionByUserID;

  TripEndInspectionRentout(
      {this.isNoticibleDamage,
        this.damageImageIDs,
        this.exteriorImageIDs,
        this.interiorImageIDs,
        this.fuelImageIDs,
        this.mileageImageIDs,
        this.damageDesctiption,
        this.cleanliness,
        this.fuelLevel,
        this.mileage,
        this.fuelReceiptImageIDs,
        this.pickUpFee,
        this.dropOffFee,
        this.fuelFee,
        this.interiorCleanFee,
        this.exteriorCleanFee,
        this.kmFee,

        this.exteriorCleanliness,
        this.interiorCleanliness,
        this.requestedCleaningFee,
        this.isFuelSameLevelAsBefore,
        this.requestedChargeForFuel,
        this.isAddedMileageWithinAllocated,
        this.kmOverTheLimit,
        this.isTicketsTolls,
        this.ticketsTollsReimbursement,
        this.tripID,
        this.inspectionByUserID});

  TripEndInspectionRentout.fromJson(Map<String, dynamic> json) {
    isNoticibleDamage = json['IsNoticibleDamage'];

    damageImageIDs = json['DamageImageIDs'].cast<String>();
    exteriorImageIDs = json['ExteriorImageIDs'].cast<String>();
    pickUpFee = json['PickUpFee'];
    dropOffFee = json['DropOffFee'];
    fuelFee = json['FuelFee'];
    kmFee = json['KMfee'];
    exteriorCleanFee = json['ExteriorCleanFee'];
    interiorCleanFee = json['InteriorCleanFee'];
    interiorImageIDs = json['InteriorImageIDs'].cast<String>();
    fuelImageIDs = json['FuelImageIDs'].cast<String>();
    mileageImageIDs = json['MileageImageIDs'].cast<String>();
    fuelReceiptImageIDs = json['FuelReceiptImageIDs'].cast<String>();
    damageDesctiption = json['DamageDesctiption'];
    cleanliness = json['Cleanliness'];
    exteriorCleanliness = json['ExteriorCleanliness'];
    fuelLevel = json['FuelLevel'];
    mileage = json['Mileage'];
    interiorCleanliness = json['InteriorCleanliness'];
    requestedCleaningFee = json['RequestedCleaningFee'];
    isFuelSameLevelAsBefore = json['IsFuelSameLevelAsBefore'];
    requestedChargeForFuel = json['RequestedChargeForFuel'];
    isAddedMileageWithinAllocated = json['IsAddedMileageWithinAllocated'];
    kmOverTheLimit = json['KmOverTheLimit'];
    isTicketsTolls = json['IsTicketsTolls'];
    ticketsTollsReimbursement = json['TicketsTollsReimbursement'] != null
        ? new TicketsTollsReimbursement.fromJson(
        json['TicketsTollsReimbursement'])
        : null;
    tripID = json['TripID'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsNoticibleDamage'] = this.isNoticibleDamage;

    data['DamageImageIDs'] = this.damageImageIDs;
    data['ExteriorImageIDs'] = this.exteriorImageIDs;
    data['PickUpFee'] = this.pickUpFee;
    data['DropOffFee'] = this.dropOffFee;
    data['FuelFee'] = this.fuelFee;
    data['KMfee'] = this.kmFee;
    data['ExteriorCleanFee'] = this.exteriorCleanFee;
    data['InteriorCleanFee'] = this.interiorCleanFee;
    data['InteriorImageIDs'] = this.interiorImageIDs;
    data['FuelImageIDs'] = this.fuelImageIDs;
    data['MileageImageIDs'] = this.mileageImageIDs;
    data['FuelReceiptImageIDs'] = this.fuelReceiptImageIDs;
    data['DamageDesctiption'] = this.damageDesctiption;
    data['Cleanliness'] = this.cleanliness;
    data['ExteriorCleanliness'] = this.exteriorCleanliness;
    data['FuelLevel'] = this.fuelLevel;
    data['Mileage'] = this.mileage;
    data['InteriorCleanliness'] = this.interiorCleanliness;
    data['RequestedCleaningFee'] = this.requestedCleaningFee;
    data['IsFuelSameLevelAsBefore'] = this.isFuelSameLevelAsBefore;
    data['RequestedChargeForFuel'] = this.requestedChargeForFuel;
    data['IsAddedMileageWithinAllocated'] = this.isAddedMileageWithinAllocated;
    data['KmOverTheLimit'] = this.kmOverTheLimit;
    data['IsTicketsTolls'] = this.isTicketsTolls;
    if (this.ticketsTollsReimbursement != null) {
      data['TicketsTollsReimbursement'] = this.ticketsTollsReimbursement!.toJson();
    }
    data['TripID'] = this.tripID;
    data['InspectionByUserID'] = this.inspectionByUserID;
    return data;
  }
}
class TicketsTollsReimbursement {
  String? reimbursementDate;
  int? amount;
  String? description;
  List<String>? imageIDs;

  TicketsTollsReimbursement(
      {this.reimbursementDate, this.amount, this.description, this.imageIDs});

  TicketsTollsReimbursement.fromJson(Map<String, dynamic> json) {
    reimbursementDate = json['ReimbursementDate'];
    amount = int.parse(json['Amount'].toString());
    description = json['Description'];
    imageIDs = json['ImageIDs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
