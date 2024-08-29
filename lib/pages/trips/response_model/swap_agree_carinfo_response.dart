import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

class SwapAgreementCarInfoResponse {
  SwapAgreementTerms? swapAgreementTerms;
  Status? status;

  SwapAgreementCarInfoResponse({this.swapAgreementTerms, this.status});

  SwapAgreementCarInfoResponse.fromJson(Map<String, dynamic> json) {
    swapAgreementTerms = json['SwapAgreementTerms'] != null ? new SwapAgreementTerms.fromJson(json['SwapAgreementTerms']) : null;
    status = json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.swapAgreementTerms != null) {
      data['SwapAgreementTerms'] = this.swapAgreementTerms!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class SwapAgreementTerms {
  String? hash;
  String? startDateTime;
  String? endDateTime;
  Location? location;
  CarAInsurance? carAInsurance;
  CarAInsurance? carBInsurance;
  String? myCarTitle;
  TripRate? tripRate;
  double? tripPayout;
  double? tripFee;
  double? totalPayout;
  String? freeCancelBeforeDateTime;
  String? swapAgreementID;
  String? suggestedByUserID;
  String? agreedByUserID;
  String? createdAt;
  String? updatedAt;
  String? swapAgreementStatus;
  Car? theirCar;
  Car? myCar;
  PricingForCarAOwner? pricingForCarAOwner;
  PricingForCarAOwner? pricingForCarBOwner;

  SwapAgreementTerms({this.hash, this.startDateTime, this.endDateTime, this.location, this.carAInsurance, this.carBInsurance, this.myCarTitle, this.tripRate, this.tripPayout,
    this.tripFee, this.totalPayout, this.freeCancelBeforeDateTime, this.swapAgreementID,
    this.suggestedByUserID, this.agreedByUserID, this.createdAt, this.updatedAt, this.swapAgreementStatus, this.theirCar,this.myCar, this.pricingForCarAOwner, this.pricingForCarBOwner});

  SwapAgreementTerms.fromJson(Map<String, dynamic> json) {
    hash = json['Hash'];
    startDateTime = json['StartDateTime'];
    endDateTime = json['EndDateTime'];
    location = json['Location'] != null ? new Location.fromJson(json['Location']) : null;
    carAInsurance = json['CarAInsurance'] != null ? new CarAInsurance.fromJson(json['CarAInsurance']) : null;
    carBInsurance = json['CarBInsurance'] != null ? new CarAInsurance.fromJson(json['CarBInsurance']) : null;
    myCarTitle = json['MyCarTitle'];
    tripRate = json['TripRate'] != null ? new TripRate.fromJson(json['TripRate']) : null;
    tripPayout = double.parse(json['TripPayout'].toString());
    tripFee = double.parse(json['TripFee'].toString());
    totalPayout = double.parse(json['TotalPayout'].toString());
    freeCancelBeforeDateTime = json['FreeCancelBeforeDateTime'];
    swapAgreementID = json['SwapAgreementID'];
    suggestedByUserID = json['SuggestedByUserID'];
    agreedByUserID = json['AgreedByUserID'];
    createdAt = json['CreatedAt'];
    updatedAt = json['UpdatedAt'];
    swapAgreementStatus = json['SwapAgreementStatus'];
    theirCar = json['TheirCar'] != null ? new Car.fromJson(json['TheirCar']) : null;
    myCar = json['MyCar'] != null ? new Car.fromJson(json['MyCar']) : null;
    pricingForCarAOwner = json['PricingForCarAOwner'] != null ? new PricingForCarAOwner.fromJson(json['PricingForCarAOwner']) : null;
    pricingForCarBOwner = json['PricingForCarBOwner'] != null ? new PricingForCarAOwner.fromJson(json['PricingForCarBOwner']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Hash'] = this.hash;
    data['StartDateTime'] = this.startDateTime;
    data['EndDateTime'] = this.endDateTime;
    if (this.location != null) {
      data['Location'] = this.location!.toJson();
    }
    if (this.carAInsurance != null) {
      data['CarAInsurance'] = this.carAInsurance!.toJson();
    }
    if (this.carBInsurance != null) {
      data['CarBInsurance'] = this.carBInsurance!.toJson();
    }
    data['MyCarTitle'] = this.myCarTitle;
    if (this.tripRate != null) {
      data['TripRate'] = this.tripRate!.toJson();
    }
    data['TripPayout'] = this.tripPayout;
    data['TripFee'] = this.tripFee;
    data['TotalPayout'] = this.totalPayout;
    data['FreeCancelBeforeDateTime'] = this.freeCancelBeforeDateTime;
    data['SwapAgreementID'] = this.swapAgreementID;
    data['SuggestedByUserID'] = this.suggestedByUserID;
    data['AgreedByUserID'] = this.agreedByUserID;
    data['CreatedAt'] = this.createdAt;
    data['UpdatedAt'] = this.updatedAt;
    data['SwapAgreementStatus'] = this.swapAgreementStatus;
    if (this.theirCar != null) {
      data['TheirCar'] = this.theirCar!.toJson();
    }
    if (this.myCar != null) {
      data['MyCar'] = this.myCar!.toJson();
    }
    if (this.pricingForCarAOwner != null) {
      data['PricingForCarAOwner'] = this.pricingForCarAOwner!.toJson();
    }
    if (this.pricingForCarBOwner != null) {
      data['PricingForCarBOwner'] = this.pricingForCarBOwner!.toJson();
    }
    return data;
  }
}

class Location {
  String? address;
  LatLng? latLng;

  Location({this.address, this.latLng});

  Location.fromJson(Map<String, dynamic> json) {
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

class CarAInsurance {
  String? carID;
  String? insuranceType;

  CarAInsurance({this.carID, this.insuranceType});

  CarAInsurance.fromJson(Map<String, dynamic> json) {
    carID = json['carID'];
    insuranceType = json['InsuranceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['carID'] = this.carID;
    data['InsuranceType'] = this.insuranceType;
    return data;
  }
}

class TripRate {
  int? numberOfDays;
  double? ratePerDay;

  TripRate({this.numberOfDays, this.ratePerDay});

  TripRate.fromJson(Map<String, dynamic> json) {
    numberOfDays = json['NumberOfDays'];
    ratePerDay = double.parse(json['RatePerDay'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NumberOfDays'] = this.numberOfDays;
    data['RatePerDay'] = this.ratePerDay;
    return data;
  }
}

class PricingForCarAOwner {
  double? recievable;
  double? payable;
  double? income;
  double? insuranceFee;
  double? ridealikeFee;
  double? discountPercentage;
  double? discount;
  double? ridealikeCoupon;
  double? cancellationFee;
  double? total;
  double? providedDiscount;
  String? payableInString;
  String? recievableInString;

  PricingForCarAOwner({this.recievable, this.payable, this.income, this.insuranceFee, this.ridealikeFee, this.discountPercentage, this.discount, this.ridealikeCoupon, this.cancellationFee, this.total, this.providedDiscount, this.payableInString, this.recievableInString});

  PricingForCarAOwner.fromJson(Map<String, dynamic> json) {
    recievable = double.tryParse(json['Recievable'].toString());
    payable = double.tryParse(json['Payable'].toString()) ;
    income =  double.tryParse(json['income'].toString());
    insuranceFee =  double.tryParse(json['insuranceFee'].toString());
    ridealikeFee =  double.tryParse(json['RidealikeFee'].toString());
    discountPercentage =  double.tryParse(json['DiscountPercentage'].toString());
    discount = double.tryParse( json['Discount'].toString());
    ridealikeCoupon = double.tryParse(json['RidealikeCoupon'].toString()) ;
    cancellationFee =  double.tryParse(json['CancellationFee'].toString());
    total = double.tryParse( json['Total'].toString());
    providedDiscount =  double.tryParse(json['ProvidedDiscount'].toString());
    payableInString = json['PayableInString'];
    recievableInString = json['RecievableInString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Recievable'] = this.recievable;
    data['Payable'] = this.payable;
    data['income'] = this.income;
    data['insuranceFee'] = this.insuranceFee;
    data['RidealikeFee'] = this.ridealikeFee;
    data['DiscountPercentage'] = this.discountPercentage;
    data['Discount'] = this.discount;
    data['RidealikeCoupon'] = this.ridealikeCoupon;
    data['CancellationFee'] = this.cancellationFee;
    data['Total'] = this.total;
    data['ProvidedDiscount'] = this.providedDiscount;
    data['PayableInString'] = this.payableInString;
    data['RecievableInString'] = this.recievableInString;
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
