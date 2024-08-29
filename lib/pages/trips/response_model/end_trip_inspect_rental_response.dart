class InspectTripEndRentalResponse {
  TripEndInspectionRental? tripEndInspectionRental;
  Status? status;

  InspectTripEndRentalResponse({this.tripEndInspectionRental, this.status});

  InspectTripEndRentalResponse.fromJson(Map<String, dynamic> json) {
    tripEndInspectionRental = json['TripEndInspectionRental'] != null
        ? new TripEndInspectionRental.fromJson(json['TripEndInspectionRental'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tripEndInspectionRental != null) {
      data['TripEndInspectionRental'] = this.tripEndInspectionRental!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class TripEndInspectionRental {
  bool? isNoticibleDamage;
  List<String>? damageImageIDs;
  String? damageDesctiption;
  int? mileage;
  List<String>? fuelReceiptImageIDs;
  List<String>? exteriorImageIDs;
  List<String>? interiorImageIDs;
  List<String>? fuelImageIDs;
  List<String>? mileageImageIDs;
  String? exteriorCleanliness;
  String? interiorCleanliness;
  String? fuelLevel;
  String? tripID;
  String? inspectionByUserID;

  TripEndInspectionRental(
      {this.isNoticibleDamage,
        this.damageImageIDs,
        this.damageDesctiption,
        this.mileage,
        this.fuelReceiptImageIDs,
        this.exteriorImageIDs,
        this.interiorImageIDs,
        this.fuelImageIDs,
        this.mileageImageIDs,
        this.exteriorCleanliness,
        this.interiorCleanliness,
        this.fuelLevel,
        this.tripID,
        this.inspectionByUserID});

  TripEndInspectionRental.fromJson(Map<String, dynamic> json) {
    isNoticibleDamage = json['IsNoticibleDamage'];
    damageImageIDs = json['DamageImageIDs'].cast<String>();
    damageDesctiption = json['DamageDesctiption'];
    exteriorCleanliness = json['ExteriorCleanliness'];
    interiorCleanliness = json['InteriorCleanliness'];
    exteriorImageIDs = json['ExteriorImageIDs'].cast<String>();
    fuelLevel = json['FuelLevel'];
    mileage = json['Mileage'];
    fuelImageIDs = json['FuelImageIDs'].cast<String>();
    mileageImageIDs = json['MileageImageIDs'].cast<String>();
    fuelReceiptImageIDs = json['FuelReceiptImageIDs'].cast<String>();
    tripID = json['TripID'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsNoticibleDamage'] = this.isNoticibleDamage;
    data['DamageImageIDs'] = this.damageImageIDs;
    data['DamageDesctiption'] = this.damageDesctiption;
    data['ExteriorCleanliness'] = this.exteriorCleanliness;
    data['ExteriorImageIDs'] = this.exteriorImageIDs;
    data['InteriorCleanliness'] = this.interiorCleanliness;
    data['FuelLevel'] = this.fuelLevel;
    data['Mileage'] = this.mileage;
    data['FuelImageIDs'] = this.fuelImageIDs;
    data['MileageImageIDs'] = this.mileageImageIDs;
    data['FuelReceiptImageIDs'] = this.fuelReceiptImageIDs;
    data['TripID'] = this.tripID;
    data['InspectionByUserID'] = this.inspectionByUserID;
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
