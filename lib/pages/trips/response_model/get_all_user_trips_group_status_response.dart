import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';

class TripAllUserStatusGroupResponse {
  List<Trips>? trips;
  String? totalCount;
  String? limit;
  String? skip;
  String? userID;
  String? tripStatusGroup;
  Status? status;
  String? vehicleOwnershipDocument;

  TripAllUserStatusGroupResponse(
      {this.trips,
        this.totalCount,
        this.limit,
        this.skip,
        this.userID,
        this.tripStatusGroup,
        this.vehicleOwnershipDocument,
        this.status});

  TripAllUserStatusGroupResponse.fromJson(Map<String, dynamic> json) {
    if (json['Trips'] != null) {

       trips =  <Trips>[];
      json['Trips'].forEach((v) {
        trips!.add(new Trips.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    limit = json['Limit'];
    skip = json['Skip'];
    userID = json['UserID'];
    tripStatusGroup = json['TripStatusGroup'];
    vehicleOwnershipDocument = json['VehicleOwnershipDocument'];
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trips != null) {
      data['Trips'] = this.trips!.map((v) => v.toJson()).toList();
    }
    data['TotalCount'] = this.totalCount;
    data['Limit'] = this.limit;
    data['Skip'] = this.skip;
    data['UserID'] = this.userID;
    data['TripStatusGroup'] = this.tripStatusGroup;
    data['VehicleOwnershipDocument'] = this.vehicleOwnershipDocument;
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class Trips {
  String? tripID;
  String? bookingID;
  Location? location;
  ReturnLocation? returnLocation;
  String? tripStatus;
  String? carID;
  String? hostUserID;
  String? guestUserID;
  double? tripPayout;
  DateTime? freeCancelBeforeDateTime;
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool? deliveryNeeded;
  bool? hostRatingReviewAdded;
  bool? guestRatingReviewAdded;
  bool? carRatingReviewAdded;
  String? noOfTripRequest;
  int? receiptIndex ;
  String? tripType;
  SwapData? swapData;
  String? cancellationReason;
  String? bookingEventID;
  String? rBN;
  double? guestTotal;
  List? newGuestTotal;
  double? hostTotal;
  List? newHostTotal;
  String? rentAgreementID;
  String? swapAgreementID;
  CancellationBlock? cancellationBlock;
  CancellationFee? cancellationFee;
  OtherFees? otherFees;
  DateTime? startedAt;
  DateTime? endedAt;
  Car?     car;
  Car?     myCarForSwap;
  String?  carName;
  String?  carMake;
  String?  carModel;
  String?  carImageId;
  String?  carLicense;
  String?  carYear;
  Profiles? hostProfile;
  Profiles? guestProfile;
  String? reimbursementStatus;
  bool? changeRequest;
  String? userID;

  Trips(
      {this.tripID,
        this.bookingID,
        this.location,
        this.returnLocation,
        this.tripStatus,
        this.carID,
        this.hostUserID,
        this.guestUserID,
        this.tripPayout,
        this.freeCancelBeforeDateTime,
        this.startDateTime,
        this.endDateTime,
        this.receiptIndex,
        this.deliveryNeeded,
        this.hostRatingReviewAdded,
        this.guestRatingReviewAdded,
        this.carRatingReviewAdded,
        this.tripType,
        this.swapData,
        this.bookingEventID,
        this.rBN,
        this.noOfTripRequest,
        this.guestTotal,
        this.newGuestTotal,
        this.hostTotal,
        this.newHostTotal,
        this.rentAgreementID,
        this.swapAgreementID,
        this.cancellationBlock,
        this.cancellationFee,
        this.otherFees,
        this.startedAt,
        this.endedAt,
        this.reimbursementStatus,
        this.changeRequest
      });

  Trips.fromJson(Map<String, dynamic> json) {
    tripID = json['TripID'];
    bookingID = json['BookingID'];
    location = json['Location'] != null
        ? new Location.fromJson(json['Location'])
        : null;
    returnLocation = json['ReturnLocation'] != null
        ? ReturnLocation.fromJson(json['ReturnLocation'])
        : null;
    tripStatus = json['TripStatus'];
    carID = json['CarID'];
    hostUserID = json['HostUserID'];
    guestUserID = json['GuestUserID'];
    tripPayout = double.tryParse(json['TripPayout'].toString());
    freeCancelBeforeDateTime =json['FreeCancelBeforeDateTime']== null? null: DateTime.parse(json['FreeCancelBeforeDateTime']);
    startDateTime = json['StartDateTime']== null? null:DateTime.parse(json['StartDateTime']);
    endDateTime = json['EndDateTime']== null? null:DateTime.parse(json['EndDateTime']);
    deliveryNeeded = json['DeliveryNeeded'];
    hostRatingReviewAdded = json['HostRatingReviewAdded'];
    guestRatingReviewAdded = json['GuestRatingReviewAdded'];
    carRatingReviewAdded = json['CarRatingReviewAdded'];
    tripType = json['TripType'];
    swapData = json['SwapData'] != null
        ? new SwapData.fromJson(json['SwapData'])
        : null;
    bookingEventID = json['BookingEventID'];
    rBN = json['RBN'];
    guestTotal = double.tryParse(json['GuestTotal'].toString());
    newGuestTotal = json['NewGuestTotal'];
    hostTotal =  double.tryParse(json['HostTotal'].toString());
    newHostTotal = json["NewHostTotal"];
    rentAgreementID = json['RentAgreementID'];
    swapAgreementID = json['SwapAgreementID'];
    cancellationBlock = json['CancellationBlock'] != null
        ? new CancellationBlock.fromJson(json['CancellationBlock'])
        : null;
    cancellationFee = json['CancellationFee'] != null
        ? new CancellationFee.fromJson(json['CancellationFee'])
        : null;
    otherFees = json['OtherFees'] != null
        ? new OtherFees.fromJson(json['OtherFees'])
        : null;
    startedAt = json['StartedAt']== null? null:DateTime.parse(json['StartedAt']);
    endedAt =  json['EndedAt']== null? null:DateTime.parse(json['EndedAt']);
    reimbursementStatus = json['ReimbursementStatus'];
    changeRequest = json['ChangeRequest'];
  }

  fromJsonTrips(Map<String, dynamic> json) {
    tripID = json['TripID'];
    bookingID = json['BookingID'];
    location = json['Location'] != null
        ? new Location.fromJson(json['Location'])
        : null;
    returnLocation = json['ReturnLocation'] != null
        ? ReturnLocation.fromJson(json['ReturnLocation'])
        : null;
    tripStatus = json['TripStatus'];
    carID = json['CarID'];
    hostUserID = json['HostUserID'];
    guestUserID = json['GuestUserID'];
    tripPayout = double.parse(json['TripPayout'].toString());
    freeCancelBeforeDateTime = DateTime.parse(json['FreeCancelBeforeDateTime']);
    startDateTime = DateTime.parse(json['StartDateTime']);
    endDateTime = DateTime.parse(json['EndDateTime']);
    deliveryNeeded = json['DeliveryNeeded'];
    hostRatingReviewAdded = json['HostRatingReviewAdded'];
    guestRatingReviewAdded = json['GuestRatingReviewAdded'];
    carRatingReviewAdded = json['CarRatingReviewAdded'];
    tripType = json['TripType'];
    swapData = json['SwapData'] != null
        ? new SwapData.fromJson(json['SwapData'])
        : null;
    bookingEventID = json['BookingEventID'];
    rBN = json['RBN'];
    guestTotal =  double.parse(json['GuestTotal'].toString());
    hostTotal =  double.parse(json['HostTotal'].toString());
    rentAgreementID = json['RentAgreementID'];
    swapAgreementID=json['SwapAgreementID'];
    cancellationBlock = json['CancellationBlock'] != null
        ? new CancellationBlock.fromJson(json['CancellationBlock'])
        : null;
    cancellationFee = json['CancellationFee'] != null
        ? new CancellationFee.fromJson(json['CancellationFee'])
        : null;
    otherFees = json['OtherFees'] != null
        ? new OtherFees.fromJson(json['OtherFees'])
        : null;
    startedAt= json['StartedAt']== null? null:DateTime.parse(json['StartedAt']);
    endedAt =  json['EndedAt']== null? null:DateTime.parse(json['EndedAt']);
    reimbursementStatus = json['ReimbursementStatus'];
    changeRequest = json['ChangeRequest'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TripID'] = this.tripID;
    data['BookingID'] = this.bookingID;
    if (this.location != null) {
      data['Location'] = this.location!.toJson();
    }
    data['TripStatus'] = this.tripStatus;
    data['CarID'] = this.carID;
    data['HostUserID'] = this.hostUserID;
    data['GuestUserID'] = this.guestUserID;
    data['TripPayout'] = this.tripPayout;
    data['FreeCancelBeforeDateTime'] = this.freeCancelBeforeDateTime;
    data['StartDateTime'] = this.startDateTime;
    data['EndDateTime'] = this.endDateTime;
    data['DeliveryNeeded'] = this.deliveryNeeded;
    data['HostRatingReviewAdded'] = this.hostRatingReviewAdded;
    data['GuestRatingReviewAdded'] = this.guestRatingReviewAdded;
    data['CarRatingReviewAdded'] = this.carRatingReviewAdded;
    data['TripType'] = this.tripType;
    if (this.swapData != null) {
      data['SwapData'] = this.swapData!.toJson();
    }
    data['BookingEventID'] = this.bookingEventID;
    data['RBN'] = this.rBN;
    data['GuestTotal'] = this.guestTotal;
    data['HostTotal'] = this.hostTotal;
    data['RentAgreementID'] = this.rentAgreementID;
    data['SwapAgreementID'] = this.swapAgreementID;
    if (this.cancellationBlock != null) {
      data['CancellationBlock'] = this.cancellationBlock!.toJson();
    }
    if (this.cancellationFee != null) {
      data['CancellationFee'] = this.cancellationFee!.toJson();
    }
    if (this.otherFees != null) {
      data['OtherFees'] = this.otherFees!.toJson();
    }
    data['StartedAt'] = this.startedAt;
    data['EndedAt'] = this.endedAt;
    data['ReimbursementStatus'] = this.reimbursementStatus;
    return data;
  }
}

class Location {
  String? address;
  String? formattedAddress;
  LatLng? latLng;
  bool? customLoc;
  Location({this.address,this.formattedAddress, this.latLng,this.customLoc});

  Location.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    formattedAddress = json['FormattedAddress'];
    latLng =
    json['LatLng'] != null ? new LatLng.fromJson(json['LatLng']) : null;
    customLoc = json['CustomLoc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    data['FormattedAddress'] = this.formattedAddress;
    if (this.latLng != null) {
      data['LatLng'] = this.latLng!.toJson();
    }
    data['CustomLoc'] = this.customLoc;
    return data;
  }
}

class ReturnLocation {
  String? address;
  String? formattedAddress;
  LatLng? latLng;
  bool? customLoc;
  ReturnLocation({this.address,this.formattedAddress, this.latLng,this.customLoc});

  ReturnLocation.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    formattedAddress = json['FormattedAddress'];
    latLng =
    json['LatLng'] != null ? new LatLng.fromJson(json['LatLng']) : null;
    customLoc = json['CustomLoc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    data['FormattedAddress'] = this.formattedAddress;
    if (this.latLng != null) {
      data['LatLng'] = this.latLng!.toJson();
    }
    data['CustomLoc'] = this.customLoc;
    return data;
  }
}

class LatLng {
  dynamic latitude;
  dynamic longitude;

  LatLng({this.latitude, this.longitude});

  LatLng.fromJson(Map<String, dynamic> json) {
    latitude = json['Latitude'];
    longitude = json['Longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    return data;
  }
}

class OtherFees {
 double? latePickup;
 double? lateReturn;
 double? extraMileage;
 double? fuelCharge;
 double? cleaning;
 double? toll;
 double? damage;
 HostProfit? hostProfit;
  OtherFees(
      {this.latePickup,
        this.lateReturn,
        this.extraMileage,
        this.fuelCharge,
        this.cleaning,this.damage,
        this.toll,this.hostProfit});

  OtherFees.fromJson(Map<String, dynamic> json) {
    latePickup = double.parse(json['LatePickup'].toString());
    lateReturn = double.parse(json['LateReturn'].toString());

    extraMileage = double.parse(json['ExtraMileage'].toString());
    fuelCharge = double.parse(json['FuelCharge'].toString());
    cleaning = double.parse(json['Cleaning'].toString());
    toll = double.parse(json['Toll'].toString());
    damage = double.parse(json['Damage'].toString());
    hostProfit = json['HostProfit'] != null
        ? new HostProfit.fromJson(json['HostProfit'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LatePickup'] = this.latePickup;
    data['LateReturn'] = this.lateReturn;
    data['ExtraMileage'] = this.extraMileage;
    data['FuelCharge'] = this.fuelCharge;
    data['Cleaning'] = this.cleaning;
    data['Toll'] = this.toll;
    data['Damage'] = this.damage;
    if (this.hostProfit != null) {
      data['HostProfit'] = this.hostProfit!.toJson();
    }
    return data;
  }
}
class HostProfit {
  double? latePickup;
  double? lateReturn;

  HostProfit({this.latePickup, this.lateReturn});

  HostProfit.fromJson(Map<String, dynamic> json) {
    latePickup = double.parse(json['LatePickup'].toString());
    lateReturn =double.parse(json['LateReturn'].toString());

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['LatePickup'] = this.latePickup;
    data['LateReturn'] = this.lateReturn;
    return data;
  }
}
class SwapData {
  String? myCarID;
  String? otherTripID, SBN;

  SwapData({this.myCarID, this.otherTripID, this.SBN});

  SwapData.fromJson(Map<String, dynamic> json) {
    myCarID = json['MyCarID'];
    otherTripID = json['OtherTripID'];
    SBN = json['SBN'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MyCarID'] = this.myCarID;
    data['OtherTripID'] = this.otherTripID;
    data['SBN'] = this.SBN;
    return data;
  }
}
class CancellationBlock {
  String? cancelledByUserID;
  String? whoCancelled;

  CancellationBlock({this.cancelledByUserID, this.whoCancelled});

  CancellationBlock.fromJson(Map<String, dynamic> json) {
    cancelledByUserID = json['CancelledByUserID'];
    whoCancelled = json['WhoCancelled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CancelledByUserID'] = this.cancelledByUserID;
    data['WhoCancelled'] = this.whoCancelled;
    return data;
  }
}
class CancellationFee {
  String? cancelledByUserID;
  String? whoCancelled;
  double? cancellationFee;
  double? total;
  String? cancelledDate;
  CancellationProfit? cancellationProfit;
  double? refund;

  CancellationFee(
      {this.cancelledByUserID,
        this.whoCancelled,
        this.cancellationFee,
        this.total,
        this.cancelledDate,
        this.cancellationProfit,
        this.refund});

  CancellationFee.fromJson(Map<String, dynamic> json) {
    cancelledByUserID = json['CancelledByUserID'];
    whoCancelled = json['WhoCancelled'];
    cancellationFee = double.tryParse(json['CancellationFee'].toString());
    total = double.tryParse(json['Total'].toString());
    cancelledDate = json['CancelledDate'];
    cancellationProfit = json['CancellationProfit'] != null
        ? new CancellationProfit.fromJson(json['CancellationProfit'])
        : null;
    refund =double.tryParse(json['Refund'].toString()) ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CancelledByUserID'] = this.cancelledByUserID;
    data['WhoCancelled'] = this.whoCancelled;
    data['CancellationFee'] = this.cancellationFee;
    data['Total'] = this.total;
    data['CancelledDate'] = this.cancelledDate;
    if (this.cancellationProfit != null) {
      data['CancellationProfit'] = this.cancellationProfit!.toJson();
    }
    data['Refund'] = this.refund;
    return data;
  }
}
class CancellationProfit {
  String? whoGained;
  String? whoProfittedUserID;
  String? whoPaid;
  String? whoPaidUserID;
  double? ammount;
  String? remarks;

  CancellationProfit(
      {this.whoGained, this.whoProfittedUserID,  this.whoPaid,
        this.whoPaidUserID,this.ammount, this.remarks});

  CancellationProfit.fromJson(Map<String, dynamic> json) {
    whoGained = json['WhoGained'];
    whoProfittedUserID = json['WhoProfittedUserID'];
    whoPaid = json['WhoPaid'];
    whoPaidUserID = json['WhoPaidUserID'];
    ammount =double.tryParse(json['Ammount'].toString()) ;
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WhoGained'] = this.whoGained;
    data['WhoProfittedUserID'] = this.whoProfittedUserID;
    data['WhoPaid'] = this.whoPaid;
    data['WhoPaidUserID'] = this.whoPaidUserID;
    data['Ammount'] = this.ammount;
    data['Remarks'] = this.remarks;
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
