class HostInspectTripStartResponse {
  TripStartInspection? tripStartInspection;
  Status? status;

  HostInspectTripStartResponse({this.tripStartInspection, this.status});

  HostInspectTripStartResponse.fromJson(Map<String, dynamic> json) {
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
  String? damageDesctiption;
  String? exteriorCleanliness;
  List<String>? exteriorImageIDs;
  String? interiorCleanliness;
  List<String>? interiorImageIDs;
  String? fuelLevel;
  int? mileage;
  int? mileageController;
  List<String>? fuelImageIDs;
  List<String>? mileageImageIDs;
  String? tripID;
  String? inspectionByUserID;
  List<String>? dashboardImageIDs;

  TripStartInspection(
      {this.isNoticibleDamage,
        this.damageImageIDs,
        this.exteriorCleanliness,
        this.exteriorImageIDs,
        this.damageDesctiption,
        this.interiorCleanliness,
        this.interiorImageIDs,
        this.fuelLevel,
        this.mileage,
        this.mileageController,
        this.fuelImageIDs,
        this.mileageImageIDs,
        this.tripID,
        this.inspectionByUserID,
        this.dashboardImageIDs});

  TripStartInspection.fromJson(Map<String, dynamic> json) {
    isNoticibleDamage = json['IsNoticibleDamage'];
    damageImageIDs = json['DamageImageIDs'].cast<String>();
    dashboardImageIDs = json['dashboardImageIDs'];
    damageDesctiption = json['DamageDesctiption'];
    exteriorCleanliness = json['ExteriorCleanliness'];
    exteriorImageIDs = json['ExteriorImageIDs'].cast<String>();
    interiorCleanliness = json['InteriorCleanliness'];
    interiorImageIDs = json['InteriorImageIDs'].cast<String>();
    fuelLevel = json['FuelLevel'];
    mileage = json['Mileage'];

    fuelImageIDs = json['FuelImageIDs'].cast<String>();
    mileageImageIDs = json['MileageImageIDs'].cast<String>();
    tripID = json['TripID'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsNoticibleDamage'] = this.isNoticibleDamage;
    data['DamageImageIDs'] = this.damageImageIDs;
    data['DamageDesctiption'] = this.damageDesctiption;
    data['DashboardImageIDs'] = this.dashboardImageIDs;
    data['ExteriorCleanliness'] = this.exteriorCleanliness;
    data['ExteriorImageIDs'] = this.exteriorImageIDs;
    data['InteriorCleanliness'] = this.interiorCleanliness;
    data['InteriorImageIDs'] = this.interiorImageIDs;
    data['FuelLevel'] = this.fuelLevel;
    data['Mileage'] = this.mileage;
    data['mileageController'] = this.mileageController;
    data['FuelImageIDs'] = this.fuelImageIDs;
    data['MileageImageIDs'] = this.mileageImageIDs;
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