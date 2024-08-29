import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

class RentAgreementCarInfoResponse {
  RentAgreement? rentAgreement;
  Status? status;

  RentAgreementCarInfoResponse({this.rentAgreement, this.status});

  RentAgreementCarInfoResponse.fromJson(Map<String, dynamic> json) {
    rentAgreement = json['RentAgreement'] != null ? new RentAgreement.fromJson(json['RentAgreement']) : null;
    status = json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rentAgreement != null) {
      data['RentAgreement'] = this.rentAgreement!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class RentAgreement {
  String? rentAgreementID;
  String? startDateTime;
  String? endDateTime;
  PickupReturnLocation? pickupReturnLocation;
  double? insuranceFee;
  Car? car;
  double? coupon;

  RentAgreement({this.rentAgreementID, this.startDateTime, this.endDateTime, this.pickupReturnLocation, this.insuranceFee, this.car, this.coupon});

  RentAgreement.fromJson(Map<String, dynamic> json) {
    rentAgreementID = json['RentAgreementID'];
    startDateTime = json['StartDateTime'];
    endDateTime = json['EndDateTime'];
    pickupReturnLocation = json['PickupReturnLocation'] != null ? new PickupReturnLocation.fromJson(json['PickupReturnLocation']) : null;
    insuranceFee =double.tryParse( json['InsuranceFee'].toString());
    car = json['Car'] != null ? new Car.fromJson(json['Car']) : null;
    coupon = double.tryParse(json['Coupon'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RentAgreementID'] = this.rentAgreementID;
    data['StartDateTime'] = this.startDateTime;
    data['EndDateTime'] = this.endDateTime;
    if (this.pickupReturnLocation != null) {
      data['PickupReturnLocation'] = this.pickupReturnLocation!.toJson();
    }
    data['InsuranceFee'] = this.insuranceFee;
    if (this.car != null) {
      data['Car'] = this.car!.toJson();
    }
    data['Coupon'] = this.coupon;
    return data;
  }
}

class PickupReturnLocation {
  String? address;
  LatLng? latLng;

  PickupReturnLocation({this.address, this.latLng});

  PickupReturnLocation.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    latLng = json['LatLng'] != null ? new LatLng.fromJson(json['LatLng']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    if (this.latLng != null) {
      data['LatLng'] = this.latLng!.toJson();
    }
    return data;
  }
}

class LatLng {
  double? latitude;
  double? longitude;

  LatLng({this.latitude, this.longitude});

  LatLng.fromJson(Map<String, dynamic> json) {
    latitude = json['Latitude'].toDouble();
    longitude = json['Longitude'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    return data;
  }
}


class SaveAndExitInfo {
  bool? saveAndExit;
  String? saveAndExitStatus;

  SaveAndExitInfo({this.saveAndExit, this.saveAndExitStatus});

  SaveAndExitInfo.fromJson(Map<String, dynamic> json) {
    saveAndExit = json['SaveAndExit'];
    saveAndExitStatus = json['SaveAndExitStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SaveAndExit'] = this.saveAndExit;
    data['SaveAndExitStatus'] = this.saveAndExitStatus;
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