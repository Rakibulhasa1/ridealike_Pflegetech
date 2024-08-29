class CreateCarResponse {
  Car? car;
  Status? status;

  CreateCarResponse({this.car, this.status});

  CreateCarResponse.fromJson(Map<String, dynamic> json) {
    car = json['Car'] != null ? new Car.fromJson(json['Car']) : null;
    status = json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.car != null) {
      data['Car'] = this.car!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class Car {
  String? iD;
  String? name;
  About? about;
  Images? mainImageID;
  ImagesAndDocuments? imagesAndDocuments;
  Features? features;
  Preference? preference;
  Availability? availability;
  Pricing? pricing;
  String? calendarID;
  Verification? verification;
  String? userID;
  String? createdAt;
  String? updatedAt;
  double? rating;
  String? numberOfTrips;
  String? totalRatingCount;
  String? swapStatus;
  SaveAndExitInfo? saveAndExitInfo;

  Car({this.iD, this.name, this.about, this.imagesAndDocuments, this.features, this.preference, this.availability, this.pricing, this.calendarID, this.verification, this.userID, this.createdAt, this.updatedAt, this.rating, this.numberOfTrips, this.totalRatingCount,this.swapStatus,this.saveAndExitInfo});

  Car.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    name = json['Name'];
    about = json['About'] != null ? new About.fromJson(json['About']) : null;
    imagesAndDocuments = json['ImagesAndDocuments'] != null ? new ImagesAndDocuments.fromJson(json['ImagesAndDocuments']) : null;
    features = json['Features'] != null ? new Features.fromJson(json['Features']) : null;
    preference = json['Preference'] != null ? new Preference.fromJson(json['Preference']) : null;
    availability = json['Availability'] != null ? new Availability.fromJson(json['Availability']) : Availability(rentalAvailability:  RentalAvailability(advanceNotice: '',bookingWindow: '',longestTrip: 0,shortestTrip: 0,sameDayCutOffTime: SameDayCutOffTime(hours: 0,seconds: 0,minutes: 0,nanos: 0)), swapAvailability: SwapAvailability(swapWithin: 0, swapVehiclesType: SwapVehiclesType( economy: false,midFullSize: false,suv: false,minivan: false,pickupTruck: false,sports: false,van: false)), completed: false);
    pricing = json['Pricing'] != null ? new Pricing.fromJson(json['Pricing']) : null;
    calendarID = json['CalendarID'];
    verification = json['Verification'] != null ? new Verification.fromJson(json['Verification']) : null;
    userID = json['UserID'];
    createdAt = json['CreatedAt'];
    updatedAt = json['UpdatedAt'];
    rating = double.tryParse(json['Rating'].toString());
    numberOfTrips = json['NumberOfTrips'];
    totalRatingCount = json['TotalRatingCount'];
    swapStatus = json['SwapStatus'];
    saveAndExitInfo = json['SaveAndExitInfo'] != null ? new SaveAndExitInfo.fromJson(json['SaveAndExitInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Name'] = this.name;
    if (this.about != null) {
      data['About'] = this.about!.toJson();
    }
    if (this.imagesAndDocuments != null) {
      data['ImagesAndDocuments'] = this.imagesAndDocuments!.toJson();
    }
    if (this.features != null) {
      data['Features'] = this.features!.toJson();
    }
    if (this.preference != null) {
      data['Preference'] = this.preference!.toJson();
    }
    if (this.availability != null) {
      data['Availability'] = this.availability!.toJson();
    }
    if (this.pricing != null) {
      data['Pricing'] = this.pricing!.toJson();
    }
    data['CalendarID'] = this.calendarID;
    if (this.verification != null) {
      data['Verification'] = this.verification!.toJson();
    }
    data['UserID'] = this.userID;
    data['CreatedAt'] = this.createdAt;
    data['UpdatedAt'] = this.updatedAt;
    data['Rating'] = this.rating;
    data['NumberOfTrips'] = this.numberOfTrips;
    data['TotalRatingCount'] = this.totalRatingCount;
    data['SwapStatus'] = this.swapStatus;
    if (this.saveAndExitInfo != null) {
      data['SaveAndExitInfo'] = this.saveAndExitInfo!.toJson();
    }

    return data;
  }
}

class About {
  String? year;
  String? carType;
  String? make;
  String? model;
  String? carBodyTrim;
  String? style;
  String? vehicleDescription;
  Location? location;
  String? carOwnedBy;
  bool? neverBrandedOrSalvageTitle;
  bool? completed;

  About({this.year, this.carType, this.make, this.model, this.carBodyTrim, this.style, this.vehicleDescription, this.location, this.carOwnedBy, this.neverBrandedOrSalvageTitle, this.completed});

  About.fromJson(Map<String, dynamic> json) {
    year = json['Year'];
    carType = json['CarType'];
    make = json['Make'];
    model = json['Model'];
    carBodyTrim = json['CarBodyTrim'];
    style = json['Style'];
    vehicleDescription = json['VehicleDescription'];
    location = json['Location'] != null ? new Location.fromJson(json['Location']) : null;
    carOwnedBy = json['CarOwnedBy'];
    neverBrandedOrSalvageTitle = json['NeverBrandedOrSalvageTitle'];
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Year'] = this.year;
    data['CarType'] = this.carType;
    data['Make'] = this.make;
    data['Model'] = this.model;
    data['CarBodyTrim'] = this.carBodyTrim;
    data['Style'] = this.style;
    data['VehicleDescription'] = this.vehicleDescription;
    if (this.location != null) {
      data['Location'] = this.location!.toJson();
    }
    data['CarOwnedBy'] = this.carOwnedBy;
    data['NeverBrandedOrSalvageTitle'] = this.neverBrandedOrSalvageTitle;
    data['Completed'] = this.completed;
    return data;
  }
}

class Location {
  String? address;
  String? formattedAddress;
  String? locality;
  String? region;
  String? postalCode;
  LatLng? latLng;
  String? notes;

  Location({this.address, this.formattedAddress, this.latLng, this.notes, this.locality, this.region, this.postalCode});

  Location.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    formattedAddress = json['FormattedAddress'];
    locality = json['Locality'];
    region = json['Region'];
    postalCode = json['PostalCode'];
    latLng = json['LatLng'] != null ? new LatLng.fromJson(json['LatLng']) : null;
    notes = json['Notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    data['FormattedAddress'] = this.formattedAddress;
    data['Locality'] = this.locality;
    data['Region'] = this.region;
    data['PostalCode'] = this.postalCode;
    if (this.latLng != null) {
      data['LatLng'] = this.latLng!.toJson();
    }
    data['Notes'] = this.notes;
    return data;
  }
}

class LatLng {
  double? latitude;
  double? longitude;
  String? formattedAddress;

  LatLng({this.latitude, this.longitude});

  LatLng.fromJson(Map<String, dynamic> json) {
    latitude = json['Latitude'].toDouble();
    longitude = json['Longitude'].toDouble();
    formattedAddress = json['FormattedAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    data['FormattedAddress'] = this.formattedAddress;
    return data;
  }
}

class ImagesAndDocuments {
  License? license;
  String? currentKilometers;
  String? carOwnershipDocumentID;
  String? carOwnershipStatus;
  String? insuranceDocumentID;
  String? insuranceCertID;
  String? insuranceCertStatus;
  String? insuranceDocStatus;
  String? vin;
  Images? images;
  bool? completed;

  ImagesAndDocuments({this.license, this.currentKilometers, this.carOwnershipDocumentID,this.carOwnershipStatus,this.insuranceDocumentID, this.insuranceDocStatus, this.vin, this.images, this.completed});

  ImagesAndDocuments.fromJson(Map<String, dynamic> json) {
    license = json['License'] != null ? new License.fromJson(json['License']) : License(plateNumber: '', province: '');
    currentKilometers = json['CurrentKilometers'];
    carOwnershipDocumentID = json['CarOwnershipDocumentID'];
    carOwnershipStatus = json['CarOwnershipStatus'];
    insuranceDocumentID = json['InsuranceDocumentID'];
    insuranceDocStatus = json['InsuranceDocStatus'];
    insuranceCertID = json['InsuranceCertID'];
    insuranceCertStatus = json['InsuranceCertStatus'];
    vin = json['Vin'];
    images = json['Images'] != null ? new Images.fromJson(json['Images']) : null;
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.license != null) {
      data['License'] = this.license!.toJson();
    }
    data['CurrentKilometers'] = this.currentKilometers;
    data['CarOwnershipDocumentID'] = this.carOwnershipDocumentID;
    data['CarOwnershipStatus'] = this.carOwnershipStatus;
    data['InsuranceDocumentID'] = this.insuranceDocumentID;
    data['InsuranceDocStatus'] = this.insuranceDocStatus;
    data['InsuranceCertID'] = this.insuranceCertID;
    data['InsuranceCertStatus'] = this.insuranceCertStatus;
    data['Vin'] = this.vin;
    if (this.images != null) {
      data['Images'] = this.images!.toJson();
    }
    data['Completed'] = this.completed;
    return data;
  }
}

class License {
  String? province;
  String? plateNumber;

  License({this.province, this.plateNumber});

  License.fromJson(Map<String, dynamic> json) {
    province = json['Province'];
    plateNumber = json['PlateNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Province'] = this.province;
    data['PlateNumber'] = this.plateNumber;
    return data;
  }
}

class Images {
  String? mainImageID;
  AdditionalImages? additionalImages;

  Images({this.mainImageID, this.additionalImages});

  Images.fromJson(Map<String, dynamic> json) {
    mainImageID = json['MainImageID'];
    additionalImages = json['AdditionalImages'] != null ? new AdditionalImages.fromJson(json['AdditionalImages']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MainImageID'] = this.mainImageID;
    if (this.additionalImages != null) {
      data['AdditionalImages'] = this.additionalImages!.toJson();
    }
    return data;
  }
}

class AdditionalImages {
  String? imageID1;
  String? imageID2;
  String? imageID3;
  String? imageID4;
  String? imageID5;
  String? imageID6;
  String? imageID7;
  String? imageID8;
  String? imageID9;

  AdditionalImages({this.imageID1, this.imageID2, this.imageID3, this.imageID4, this.imageID5, this.imageID6, this.imageID7, this.imageID8, this.imageID9});

  AdditionalImages.fromJson(Map<String, dynamic> json) {
    imageID1 = json['ImageID1'];
    imageID2 = json['ImageID2'];
    imageID3 = json['ImageID3'];
    imageID4 = json['ImageID4'];
    imageID5 = json['ImageID5'];
    imageID6 = json['ImageID6'];
    imageID7 = json['ImageID7'];
    imageID8 = json['ImageID8'];
    imageID9 = json['ImageID9'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ImageID1'] = this.imageID1;
    data['ImageID2'] = this.imageID2;
    data['ImageID3'] = this.imageID3;
    data['ImageID4'] = this.imageID4;
    data['ImageID5'] = this.imageID5;
    data['ImageID6'] = this.imageID6;
    data['ImageID7'] = this.imageID7;
    data['ImageID8'] = this.imageID8;
    data['ImageID9'] = this.imageID9;
    return data;
  }
}

class Features {
  String? fuelType;
  String? transmission;
  int? numberOfDoors;
  int? numberOfSeats;
  String? greenFeature;
  String? truckBoxSize;
  Interior? interior;
  Exterior? exterior;
  Comfort? comfort;
  SafetyAndPrivacy? safetyAndPrivacy;
  List<CustomFeatures>? customFeatures;
  bool? completed;

  Features({this.fuelType, this.transmission,this.greenFeature, this.numberOfDoors, this.numberOfSeats, this.truckBoxSize, this.interior, this.exterior, this.comfort, this.safetyAndPrivacy, this.customFeatures, this.completed});

  Features.fromJson(Map<String, dynamic> json) {
    fuelType = json['FuelType'];
    transmission = json['Transmission'];
    greenFeature = json['GreenFeature'];
    numberOfDoors = json['NumberOfDoors'];
    numberOfSeats = json['NumberOfSeats'];
    truckBoxSize = json['TruckBoxSize'];
    interior = json['Interior'] != null ? new Interior.fromJson(json['Interior']) :
    Interior(hasAirConditioning: false, hasHeatedSeats: false , hasVentilatedSeats: false , hasBluetoothAudio: false, hasAppleCarPlay: false , hasAndroidAuto: false, hasSunroof: false, hasUsbChargingPort: false);
    exterior = json['Exterior'] != null ? new Exterior.fromJson(json['Exterior']) : Exterior(hasAllWheelDrive: false, hasBikeRack: false, hasSkiRack: false, hasSnowTires: false);
    comfort = json['Comfort'] != null ? new Comfort.fromJson(json['Comfort']) :
    Comfort(freeWifi: false, remoteStart: false);
    safetyAndPrivacy = json['SafetyAndPrivacy'] != null ? new SafetyAndPrivacy.fromJson(json['SafetyAndPrivacy']) :
    SafetyAndPrivacy(hasChildSeat: false, hasDashCamera: false, hasGPSTrackingDevice: false, hasSpareTire: false);
    customFeatures =  <CustomFeatures>[];
    if (json['CustomFeatures'] != null) {
      json['CustomFeatures'].forEach((v) { customFeatures!.add(new CustomFeatures.fromJson(v)); });
    }
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FuelType'] = this.fuelType;
    data['Transmission'] = this.transmission;
    data['GreenFeature'] = this.greenFeature;
    data['NumberOfDoors'] = this.numberOfDoors;
    data['NumberOfSeats'] = this.numberOfSeats;
    data['TruckBoxSize'] = this.truckBoxSize;
    if (this.interior != null) {
      data['Interior'] = this.interior!.toJson();
    }
    if (this.exterior != null) {
      data['Exterior'] = this.exterior!.toJson();
    }
    if (this.comfort != null) {
      data['Comfort'] = this.comfort!.toJson();
    }
    if (this.safetyAndPrivacy != null) {
      data['SafetyAndPrivacy'] = this.safetyAndPrivacy!.toJson();
    }
    if (this.customFeatures != null) {
      data['CustomFeatures'] = this.customFeatures!.map((v) => v.toJson()).toList();
    }
    data['Completed'] = this.completed;
    return data;
  }
}

class Interior {
  bool? hasAirConditioning;
  bool? hasHeatedSeats;
  bool? hasVentilatedSeats;
  bool? hasBluetoothAudio;
  bool? hasAppleCarPlay;
  bool? hasAndroidAuto;
  bool? hasSunroof;
  bool? hasUsbChargingPort;

  Interior({this.hasAirConditioning, this.hasHeatedSeats, this.hasVentilatedSeats, this.hasBluetoothAudio, this.hasAppleCarPlay, this.hasAndroidAuto, this.hasSunroof, this.hasUsbChargingPort});


  Interior.fromJson(Map<String, dynamic> json) {
    hasAirConditioning = json['HasAirConditioning'];
    hasHeatedSeats = json['HasHeatedSeats'];
    hasVentilatedSeats = json['HasVentilatedSeats'];
    hasBluetoothAudio = json['HasBluetoothAudio'];
    hasAppleCarPlay = json['HasAppleCarPlay'];
    hasAndroidAuto = json['HasAndroidAuto'];
    hasSunroof = json['HasSunroof'];
    hasUsbChargingPort = json['HasUsbChargingPort'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['HasAirConditioning'] = this.hasAirConditioning;
    data['HasHeatedSeats'] = this.hasHeatedSeats;
    data['HasVentilatedSeats'] = this.hasVentilatedSeats;
    data['HasBluetoothAudio'] = this.hasBluetoothAudio;
    data['HasAppleCarPlay'] = this.hasAppleCarPlay;
    data['HasAndroidAuto'] = this.hasAndroidAuto;
    data['HasSunroof'] = this.hasSunroof;
    data['HasUsbChargingPort'] = this.hasUsbChargingPort;
    return data;
  }
}

class Exterior {
  bool? hasAllWheelDrive;
  bool? hasBikeRack;
  bool? hasSkiRack;
  bool? hasSnowTires;

  Exterior({this.hasAllWheelDrive, this.hasBikeRack, this.hasSkiRack, this.hasSnowTires});

  Exterior.fromJson(Map<String, dynamic> json) {
    hasAllWheelDrive = json['HasAllWheelDrive'];
    hasBikeRack = json['HasBikeRack'];
    hasSkiRack = json['HasSkiRack'];
    hasSnowTires = json['HasSnowTires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['HasAllWheelDrive'] = this.hasAllWheelDrive;
    data['HasBikeRack'] = this.hasBikeRack;
    data['HasSkiRack'] = this.hasSkiRack;
    data['HasSnowTires'] = this.hasSnowTires;
    return data;
  }
}

class Comfort {
  bool? remoteStart;
  bool? freeWifi;

  Comfort({this.remoteStart, this.freeWifi});

  Comfort.fromJson(Map<String, dynamic> json) {
    remoteStart = json['RemoteStart'];
    freeWifi = json['FreeWifi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RemoteStart'] = this.remoteStart;
    data['FreeWifi'] = this.freeWifi;
    return data;
  }
}

class SafetyAndPrivacy {
  bool? hasChildSeat;
  bool? hasSpareTire;
  bool? hasGPSTrackingDevice;
  bool? hasDashCamera;

  SafetyAndPrivacy({this.hasChildSeat, this.hasSpareTire, this.hasGPSTrackingDevice, this.hasDashCamera});

  SafetyAndPrivacy.fromJson(Map<String, dynamic> json) {
    hasChildSeat = json['HasChildSeat'];
    hasSpareTire = json['HasSpareTire'];
    hasGPSTrackingDevice = json['HasGPSTrackingDevice'];
    hasDashCamera = json['HasDashCamera'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['HasChildSeat'] = this.hasChildSeat;
    data['HasSpareTire'] = this.hasSpareTire;
    data['HasGPSTrackingDevice'] = this.hasGPSTrackingDevice;
    data['HasDashCamera'] = this.hasDashCamera;
    return data;
  }
}

class CustomFeatures {
  String? name;
  String? description;
  List<String>? imageIDs;

  CustomFeatures({this.name, this.description, this.imageIDs});

  CustomFeatures.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    description = json['Description'];
    imageIDs = json['ImageIDs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Description'] = this.description;
    data['ImageIDs'] = this.imageIDs;
    return data;
  }
}

class Preference {
  bool? isSmokingAllowed;
  bool? isSuitableForPets;
  String? dailyMileageAllowance;
  int? limit;
  ListingType? listingType;
  bool? completed;

  Preference({this.isSmokingAllowed, this.isSuitableForPets, this.dailyMileageAllowance, this.limit, this.listingType, this.completed});

  Preference.fromJson(Map<String, dynamic> json) {
    isSmokingAllowed = json['IsSmokingAllowed'];
    isSuitableForPets = json['IsSuitableForPets'];
    dailyMileageAllowance = json['DailyMileageAllowance'];
    limit = json['Limit'];
    listingType = json['ListingType'] != null ? new ListingType.fromJson(json['ListingType']) : null;
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsSmokingAllowed'] = this.isSmokingAllowed;
    data['IsSuitableForPets'] = this.isSuitableForPets;
    data['DailyMileageAllowance'] = this.dailyMileageAllowance;
    data['Limit'] = this.limit;
    if (this.listingType != null) {
      data['ListingType'] = this.listingType!.toJson();
    }
    data['Completed'] = this.completed;
    return data;
  }
}

class ListingType {
  bool? rentalEnabled;
  bool? swapEnabled;

  ListingType({this.rentalEnabled, this.swapEnabled});

  ListingType.fromJson(Map<String, dynamic> json) {
    rentalEnabled = json['RentalEnabled'];
    swapEnabled = json['SwapEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RentalEnabled'] = this.rentalEnabled;
    data['SwapEnabled'] = this.swapEnabled;
    return data;
  }
}

class Availability {
  RentalAvailability? rentalAvailability;
  SwapAvailability? swapAvailability;
  bool? completed;

  Availability({this.rentalAvailability, this.swapAvailability, this.completed});

  Availability.fromJson(Map<String, dynamic> json) {
    rentalAvailability = json['RentalAvailability'] != null ? new RentalAvailability.fromJson(json['RentalAvailability']) : RentalAvailability(advanceNotice: '',bookingWindow: '',longestTrip: 0,shortestTrip: 0,sameDayCutOffTime: SameDayCutOffTime(hours: 0,seconds: 0,minutes: 0,nanos: 0));
    swapAvailability = json['SwapAvailability'] != null ? new SwapAvailability.fromJson(json['SwapAvailability']) : SwapAvailability(swapWithin: 0, swapVehiclesType: SwapVehiclesType(economy: false,midFullSize:false,minivan: false,pickupTruck: false,sports: false, suv: false,van: false,));
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rentalAvailability != null) {
      data['RentalAvailability'] = this.rentalAvailability!.toJson();
    }
    if (this.swapAvailability != null) {
      data['SwapAvailability'] = this.swapAvailability!.toJson();
    }
    data['Completed'] = this.completed;
    return data;
  }
}

class RentalAvailability {
  String? advanceNotice;
  SameDayCutOffTime? sameDayCutOffTime;
  String? bookingWindow;
  int? shortestTrip;
  int? longestTrip;

  RentalAvailability({this.advanceNotice, this.sameDayCutOffTime, this.bookingWindow, this.shortestTrip, this.longestTrip});

  RentalAvailability.fromJson(Map<String, dynamic> json) {
    advanceNotice = json['AdvanceNotice'];
    sameDayCutOffTime = json['SameDayCutOffTime'] != null ? new SameDayCutOffTime.fromJson(json['SameDayCutOffTime']) : SameDayCutOffTime(hours: 0,seconds: 0,minutes: 0,nanos: 0);
    bookingWindow = json['BookingWindow'];
    shortestTrip = json['ShortestTrip'];
    longestTrip = json['LongestTrip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AdvanceNotice'] = this.advanceNotice;
    if (this.sameDayCutOffTime != null) {
      data['SameDayCutOffTime'] = this.sameDayCutOffTime!.toJson();
    }
    data['BookingWindow'] = this.bookingWindow;
    data['ShortestTrip'] = this.shortestTrip;
    data['LongestTrip'] = this.longestTrip;
    return data;
  }
}

class SameDayCutOffTime {
  int? hours;
  int? minutes;
  int? seconds;
  int? nanos;

  SameDayCutOffTime({this.hours, this.minutes, this.seconds, this.nanos});

  SameDayCutOffTime.fromJson(Map<String, dynamic> json) {
    hours = json['hours'];
    minutes = json['minutes'];
    seconds = json['seconds'];
    nanos = json['nanos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hours'] = this.hours;
    data['minutes'] = this.minutes;
    data['seconds'] = this.seconds;
    data['nanos'] = this.nanos;
    return data;
  }
}

class SwapAvailability {
  int? swapWithin;
  SwapVehiclesType? swapVehiclesType;

  SwapAvailability({this.swapWithin, this.swapVehiclesType});

  SwapAvailability.fromJson(Map<String, dynamic> json) {
    swapWithin = json['SwapWithin'];
    swapVehiclesType = json['SwapVehiclesType'] != null ? new SwapVehiclesType.fromJson(json['SwapVehiclesType']) : SwapVehiclesType(suv: false, economy: false, midFullSize:false,minivan: false,pickupTruck: false,sports: false,van: false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SwapWithin'] = this.swapWithin;
    if (this.swapVehiclesType != null) {
      data['SwapVehiclesType'] = this.swapVehiclesType!.toJson();
    }
    return data;
  }
}

class SwapVehiclesType {
  bool? economy;
  bool? midFullSize;
  bool? sports;
  bool? suv;
  bool? pickupTruck;
  bool? minivan;
  bool? van;

  SwapVehiclesType({this.economy,this.sports, this.midFullSize,this.suv,this.pickupTruck, this.minivan, this.van});

  SwapVehiclesType.fromJson(Map<String, dynamic> json) {
    economy = json['Economy']== null ? false: json['Economy'];
    midFullSize = json['MidFullSize']== null ? false: json['MidFullSize'];
    sports = json['Sports']== null ? false: json['Sports'];
    suv = json['SUV']== null ? false: json['SUV'];
    pickupTruck = json['PickupTruck']== null ? false: json['PickupTruck'];
    minivan = json['Minivan']== null ? false: json['Minivan'];
    van = json['Van']== null ? false: json['Van'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Economy'] = this.economy;
    data['MidFullSize'] = this.midFullSize;
    data['Sports'] = this.sports;
    data['SUV'] = this.suv;
    data['PickupTruck'] = this.pickupTruck;
    data['Minivan'] = this.minivan;
    data['Van'] = this.van;
    return data;
  }
}

class Pricing {
  RentalPricing? rentalPricing;
  SwapPricing? swapPricing;
  bool? completed;

  Pricing({this.rentalPricing, this.swapPricing, this.completed});

  Pricing.fromJson(Map<String, dynamic> json) {
    rentalPricing = json['RentalPricing'] != null ? new RentalPricing.fromJson(json['RentalPricing']) : null;
    swapPricing = json['SwapPricing'] != null ? new SwapPricing.fromJson(json['SwapPricing']) : null;
    completed = json['Completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rentalPricing != null) {
      data['RentalPricing'] = this.rentalPricing!.toJson();
    }
    if (this.swapPricing != null) {
      data['SwapPricing'] = this.swapPricing!.toJson();
    }
    data['Completed'] = this.completed;
    return data;
  }
}

class RentalPricing {
  double? perHour;
  double? perDay;
  double? perExtraKMOverLimit;
  bool? enableCustomDelivery;
  double? perKMRentalDeliveryFee;
  double? bookForWeekDiscountPercentage;
  double? bookForMonthDiscountPercentage;
  bool? oneTime20DiscountForFirst3Users;

  RentalPricing({this.perHour, this.perDay, this.perExtraKMOverLimit, this.enableCustomDelivery, this.perKMRentalDeliveryFee, this.bookForWeekDiscountPercentage, this.bookForMonthDiscountPercentage, this.oneTime20DiscountForFirst3Users});

  RentalPricing.fromJson(Map<String, dynamic> json) {
    perHour = double.parse(json['PerHour'].toString());
    perDay = double.parse(json['PerDay'].toString());
    perExtraKMOverLimit = double.parse(json['PerExtraKMOverLimit'].toStringAsFixed(2));
    enableCustomDelivery = json['EnableCustomDelivery'];
    perKMRentalDeliveryFee = double.parse(json['PerKMRentalDeliveryFee'].toString());
    bookForWeekDiscountPercentage = double.parse(json['BookForWeekDiscountPercentage'].toString());
    bookForMonthDiscountPercentage = double.parse(json['BookForMonthDiscountPercentage'].toString());
    oneTime20DiscountForFirst3Users = json['OneTime20DiscountForFirst3Users'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PerHour'] = this.perHour;
    data['PerDay'] = this.perDay;
    data['PerExtraKMOverLimit'] = this.perExtraKMOverLimit;
    data['EnableCustomDelivery'] = this.enableCustomDelivery;
    data['PerKMRentalDeliveryFee'] = this.perKMRentalDeliveryFee;
    data['BookForWeekDiscountPercentage'] = this.bookForWeekDiscountPercentage;
    data['BookForMonthDiscountPercentage'] = this.bookForMonthDiscountPercentage;
    data['OneTime20DiscountForFirst3Users'] = this.oneTime20DiscountForFirst3Users;
    return data;
  }
}

class SwapPricing {


  SwapPricing();

SwapPricing.fromJson(Map<String, dynamic> json) {
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  return data;
}
}

class Verification {
  String? carID;
  String? carOwnershipDocumentID;
  String? verificationStatus;
  String? approvedAt;
  String? approvedBy;

  Verification({this.carID, this.carOwnershipDocumentID, this.verificationStatus, this.approvedAt, this.approvedBy});

  Verification.fromJson(Map<String, dynamic> json) {
    carID = json['CarID'];
    carOwnershipDocumentID = json['CarOwnershipDocumentID'];
    verificationStatus = json['VerificationStatus'];
    approvedAt = json['ApprovedAt'];
    approvedBy = json['ApprovedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CarID'] = this.carID;
    data['CarOwnershipDocumentID'] = this.carOwnershipDocumentID;
    data['VerificationStatus'] = this.verificationStatus;
    data['ApprovedAt'] = this.approvedAt;
    data['ApprovedBy'] = this.approvedBy;
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
