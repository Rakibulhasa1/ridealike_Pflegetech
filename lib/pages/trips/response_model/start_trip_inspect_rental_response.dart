class InspectTripStartResponse {
  TripStartInspection? tripStartInspection;
  Status? status;

  InspectTripStartResponse({this.tripStartInspection, this.status});

  InspectTripStartResponse.fromJson(Map<String, dynamic> json) {
    tripStartInspection = json['TripStartInspection'] != null
        ? new TripStartInspection.fromJson(json['TripStartInspection'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tripStartInspection != null) {
      data['TripStartInspection'] = this.tripStartInspection!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class TripStartInspection {
  bool? isNoticibleDamage;
  List<String>? damageImageIDs;
  List<String>? exteriorImageIDs;
  List<String>? interiorImageIDs;
  String? damageDesctiption;
  List<String>? dashboardImageIDs;
  List<String>? fuelImageIDs;
  String? fuelLevel;
  int? mileage;
  List<String>? mileageImageIDs;
  String? exteriorCleanliness;
  String? interiorCleanliness;
  String? tripID;
  String? inspectionByUserID;

  TripStartInspection(
      {this.isNoticibleDamage,
        this.damageImageIDs,
        this.exteriorImageIDs,
        this.interiorImageIDs,
        this.dashboardImageIDs,
        this.damageDesctiption,
        this.fuelImageIDs,
        this.fuelLevel,
        this.mileage,
        this.mileageImageIDs,
        this.exteriorCleanliness,
        this.interiorCleanliness,
        this.tripID,
        this.inspectionByUserID});

  TripStartInspection.fromJson(Map<String, dynamic> json) {
    isNoticibleDamage = json['IsNoticibleDamage'];
    damageImageIDs = json['DamageImageIDs'];
    dashboardImageIDs = json['DashboardImageIDs'];
    fuelImageIDs = json['FuelImageIDs'];
    fuelLevel = json["FuelLevel"];
    mileage = json['Mileage'];
    damageDesctiption = json['DamageDesctiption'];
    mileageImageIDs = json['MileageImageIDs'];
    exteriorCleanliness = json['ExteriorCleanliness'];

    interiorCleanliness = json['InteriorCleanliness'];
    tripID = json['TripID'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsNoticibleDamage'] = this.isNoticibleDamage;
    data['DamageImageIDs'] = this.damageImageIDs;
    data['DashboardImageIDs'] = this.dashboardImageIDs;
    data['FuelImageIDs'] = this.fuelImageIDs;
    data['DamageDesctiption'] = this.damageDesctiption;
    data['MileageImageIDs'] = this.mileageImageIDs;
    data['Mileage'] = this.mileage;
    data['ExteriorCleanliness'] = this.exteriorCleanliness;
    data['InteriorCleanliness'] = this.interiorCleanliness;
  //  data['interiorCleanliness'] = this.exteriorCleanliness;
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
