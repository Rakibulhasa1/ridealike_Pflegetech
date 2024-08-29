
class InspectionInfo {
  InspectionInfo({
    this.inspectionInfo,
    this.status,
  });

  InspectionInfoClass? inspectionInfo;
  Status? status;

  factory InspectionInfo.fromJson(Map<String, dynamic> json) => InspectionInfo(
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
  EndRental? endRental;
  EndRentout? endRentout;

  factory InspectionInfoClass.fromJson(Map<String, dynamic> json) => InspectionInfoClass(

    start:json['Start'] != null ? Start.fromJson(json['Start']) : null,
    startHost: StartHost.fromJson(json["StartHost"]),
    endRental:json['EndRental'] != null ? EndRental.fromJson(json['EndRental']) : null,
    endRentout: json['EndRentout'] != null ? EndRentout.fromJson(json['EndRentout']) : null,

    // start2: Start.fromJson(json["Start"]),
  );


  Map<String, dynamic> toJson() => {
    "Start": start!.toJson(),
    // "Start": start2,
    "StartHost": startHost!.toJson(),
    "EndRental": endRental,
    "EndRentout": endRentout,
  };
}
class Start {
  Start({
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

  factory Start.fromJson(Map<String, dynamic> json) => Start(
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

class EndRental {
  EndRental({
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

  factory EndRental.fromJson(Map<String, dynamic> json) => EndRental(
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

class EndRentout {
  EndRentout({
    this.isNoticibleDamage,
    this.pickUpFee,
    this.dropOffFee,
    this.fuelFee,
    this.interiorCleanFee,
    this.exteriorCleanFee,
    this.kmFee,
    this.isTicketsTolls,
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
      this.ticketsTollsReimbursement,
  });

  bool? isNoticibleDamage;
  bool? pickUpFee;
  bool? dropOffFee;
  bool? fuelFee;
  bool? kmFee;
  bool? interiorCleanFee;
  bool? exteriorCleanFee;
  bool? isTicketsTolls;
   TicketsTollReimbursement? ticketsTollsReimbursement;
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

  factory EndRentout.fromJson(Map<String, dynamic> json) => EndRentout(
    isNoticibleDamage: json["IsNoticibleDamage"],
    pickUpFee: json["PickUpFee"],
      dropOffFee : json['DropOffFee'],
      fuelFee : json['FuelFee'],
      kmFee : json['KMfee'],
    isTicketsTolls : json['IsTicketsTolls'],
      ticketsTollsReimbursement: json["TicketsTollsReimbursement"] != null
        ? TicketsTollReimbursement.fromJson(json["TicketsTollsReimbursement"])
        : null,
  exteriorCleanFee : json['ExteriorCleanFee'],
  interiorCleanFee : json['InteriorCleanFee'],
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
    "PickUpFee": pickUpFee,
    "DropOffFee": dropOffFee,
    "FuelFee": fuelFee,
    "KMfee": kmFee,
    "ExteriorCleanFee": exteriorCleanFee,
    "InteriorCleanFee": interiorCleanFee,
    "IsTicketsTolls": isTicketsTolls,
 "TicketsTollsReimbursement": ticketsTollsReimbursement != null
        ? ticketsTollsReimbursement!.toJson()
        : null,
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
class TicketsTollReimbursement {

  int? amount;


  TicketsTollReimbursement(
      { this.amount, });


  factory TicketsTollReimbursement.fromJson(Map<String, dynamic> json) {
    return TicketsTollReimbursement(
      amount: int.parse(json['Amount'].toString()),
    );
  }


  Map<String, dynamic> toJson() => {
    "Amount": amount,
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
