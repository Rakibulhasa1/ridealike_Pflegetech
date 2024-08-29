class GuestStartInspection {
  GuestStartInspection({
    this.inspectionInfo,
    this.status,
  });

  InspectionInfoClass? inspectionInfo;
  Status? status;

  factory GuestStartInspection.fromJson(Map<String, dynamic> json) => GuestStartInspection(
    inspectionInfo: InspectionInfoClass.fromJson(json["InspectionInfo"]),
    status: Status.fromJson(json["Status"]),
  );

  Map<String, dynamic> toJson() => {
    "InspectionInfo": inspectionInfo!.toJson(),
    "Status": status!.toJson(),
  };
}

class InspectionInfoClass {
  InspectionInfoClass({
    this.start,
    this.startHost,
    this.endRental,
    this.endRentout,
  });

  Start? start;
  StartHost? startHost;
  dynamic? endRental;
  dynamic? endRentout;

  factory InspectionInfoClass.fromJson(Map<String, dynamic> json) => InspectionInfoClass(
    start: Start.fromJson(json["Start"]),
    startHost: StartHost.fromJson(json["StartHost"]),
    endRental: json["EndRental"],
    endRentout: json["EndRentout"],
  );

  Map<String, dynamic> toJson() => {
    "Start": start!.toJson(),
    "StartHost": startHost!.toJson(),
    "EndRental": endRental,
    "EndRentout": endRentout,
  };
}
class StartHost {
  StartHost({
    this.isNoticibleDamage,
    this.damageImageIDs,
    this.exteriorCleanliness,
    this.exteriorImageIDs,
    this.interiorCleanliness,
    this.damageDesctiption,
    this.interiorImageIDs,
    this.fuelLevel,
    this.mileage,
    this.fuelImageIDs,
    this.mileageImageIDs,
    this.tripId,
    this.inspectionByUserId,
  });

  bool? isNoticibleDamage;
  List<String>? damageImageIDs;
  String? exteriorCleanliness;
  List<String>? exteriorImageIDs;
  String? interiorCleanliness;
  List<String>? interiorImageIDs;
  String? damageDesctiption;
  String? fuelLevel;
  int? mileage;
  List<String>? fuelImageIDs;
  List<String>? mileageImageIDs;
  String? tripId;
  String? inspectionByUserId;

  factory StartHost.fromJson(Map<String, dynamic> json) => StartHost(
    isNoticibleDamage: json["IsNoticibleDamage"],
    damageImageIDs: List<String>.from(json["DamageImageIDs"].map((x) => x)),
    exteriorCleanliness: json["ExteriorCleanliness"],
    exteriorImageIDs: List<String>.from(json["ExteriorImageIDs"].map((x) => x)),
    interiorCleanliness: json["InteriorCleanliness"],
    interiorImageIDs: List<String>.from(json["InteriorImageIDs"].map((x) => x)),
    fuelLevel: json["FuelLevel"],
    mileage: json["Mileage"],
    damageDesctiption: json["DamageDesctiption"],
    fuelImageIDs: List<String>.from(json["FuelImageIDs"].map((x) => x)),
    mileageImageIDs: List<String>.from(json["MileageImageIDs"].map((x) => x)),
    tripId: json["TripID"],
    inspectionByUserId: json["InspectionByUserID"],
  );

  Map<String, dynamic> toJson() => {
    "IsNoticibleDamage": isNoticibleDamage,
    "DamageImageIDs": List<dynamic>.from(damageImageIDs!.map((x) => x)),
    "ExteriorCleanliness": exteriorCleanliness,
    "ExteriorImageIDs": List<dynamic>.from(exteriorImageIDs!.map((x) => x)),
    "InteriorCleanliness": interiorCleanliness,
    "InteriorImageIDs": List<dynamic>.from(interiorImageIDs!.map((x) => x)),
    "FuelLevel": fuelLevel,
    "DamageDesctiption": damageDesctiption,
    "Mileage": mileage,
    "FuelImageIDs": List<dynamic>.from(fuelImageIDs!.map((x) => x)),
    "MileageImageIDs": List<dynamic>.from(mileageImageIDs!.map((x) => x)),
    "TripID": tripId,
    "InspectionByUserID": inspectionByUserId,
  };
}
class Start {
  Start({
    this.isNoticibleDamage,
    this.damageImageIDs,
    this.exteriorCleanliness,
    this.exteriorImageIDs,
    this.interiorCleanliness,
    this.interiorImageIDs,
    this.fuelLevel,
    this.damageDesctiption,
    this.mileage,
    this.fuelImageIDs,
    this.mileageImageIDs,
    this.tripId,
    this.inspectionByUserId,
  });

  bool? isNoticibleDamage;
  List<String>? damageImageIDs;
  String? exteriorCleanliness;
  List<String>? exteriorImageIDs;
  String? interiorCleanliness;
  List<String>? interiorImageIDs;
  String? damageDesctiption;
  String? fuelLevel;
  int? mileage;
  List<String>? fuelImageIDs;
  List<String>? mileageImageIDs;
  String? tripId;
  String? inspectionByUserId;


  factory Start.fromJson(Map<String, dynamic> json) => Start(
    isNoticibleDamage: json["IsNoticibleDamage"],
    damageImageIDs: List<String>.from(json["DamageImageIDs"].map((x) => x)),
    exteriorCleanliness: json["ExteriorCleanliness"],
    exteriorImageIDs: List<String>.from(json["ExteriorImageIDs"].map((x) => x)),
    interiorCleanliness: json["InteriorCleanliness"],
    interiorImageIDs: List<String>.from(json["InteriorImageIDs"].map((x) => x)),
    fuelLevel: json["FuelLevel"],
    damageDesctiption: json["DamageDesctiption"],
    mileage: json["Mileage"],
    fuelImageIDs: List<String>.from(json["FuelImageIDs"].map((x) => x)),
    mileageImageIDs: List<String>.from(json["MileageImageIDs"].map((x) => x)),
    tripId: json["TripID"],
    inspectionByUserId: json["InspectionByUserID"],
  );

  Map<String, dynamic> toJson() => {
    "IsNoticibleDamage": isNoticibleDamage,
    "DamageImageIDs": List<dynamic>.from(damageImageIDs!.map((x) => x)),
    "ExteriorCleanliness": exteriorCleanliness,
    "ExteriorImageIDs": List<dynamic>.from(exteriorImageIDs!.map((x) => x)),
    "InteriorCleanliness": interiorCleanliness,
    "InteriorImageIDs": List<dynamic>.from(interiorImageIDs!.map((x) => x)),
    "FuelLevel": fuelLevel,
    "Mileage": mileage,
    "DamageDesctiption": damageDesctiption,
    "FuelImageIDs": List<dynamic>.from(fuelImageIDs!.map((x) => x)),
    "MileageImageIDs": List<dynamic>.from(mileageImageIDs!.map((x) => x)),
    "TripID": tripId,
    "InspectionByUserID": inspectionByUserId,
  };
}

class Status {
  Status({
    this.success,
    this.error,
  });

  bool? success;
  String? error;

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    success: json["success"],
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "error": error,
  };
}
