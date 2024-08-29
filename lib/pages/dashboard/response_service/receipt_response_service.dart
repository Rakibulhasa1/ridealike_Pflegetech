class RentalBookingReceiptResponse {
  Booking? booking;
  Status? status;

  RentalBookingReceiptResponse({this.booking, this.status});

  RentalBookingReceiptResponse.fromJson(Map<String, dynamic> json) {
    booking =
    json['Booking'] != null ? new Booking.fromJson(json['Booking']) : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.booking != null) {
      data['Booking'] = this.booking!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class Booking {
  String? bookingID;
  String? tripID;
  Params? params;
  Pricing? pricing;
  List? newPricing;
  double? deliveryDistance;
  String? bookingStatus;
  List<String>? logs;
  HostPricing? hostPricing;
  List<HostPricing>? newHostPricing;
  CancellationFee? cancellationFee;
  String? bookingEventID;
  String? noOfTripRequests;
  String? rBN;
  String? bookingType;
  SwapHostA? swapHostA;
  SwapHostA? swapHostB;
  String? sBN;
  String? bookingDate;

  Booking(
      {this.bookingID,
        this.tripID,
        this.params,
        this.pricing,
        this.newPricing,
        this.deliveryDistance,
        this.bookingStatus,
        this.logs,
        this.hostPricing,
        this.newHostPricing,
        this.cancellationFee,
        this.bookingEventID,
        this.noOfTripRequests,
        this.rBN,
        this.bookingType,
        this.swapHostA,
        this.swapHostB,
        this.sBN,
        this.bookingDate});

  Booking.fromJson(Map<String, dynamic> json) {
    bookingID = json['BookingID'];
    tripID = json['TripID'];
    params =
    json['Params'] != null ? new Params.fromJson(json['Params']) : null;
    pricing =
    json['Pricing'] != null ? new Pricing.fromJson(json['Pricing']) : null;
    newPricing = json["NewPricing"]!=null? List<Pricing>.from(json["NewPricing"].map((x) => Pricing.fromJson(x))):null;
    deliveryDistance = double.tryParse(json['DeliveryDistance'].toString());
    bookingStatus = json['BookingStatus'];
    logs = json['Logs'].cast<String>();
    hostPricing = json['HostPricing'] != null
        ? new HostPricing.fromJson(json['HostPricing'])
        : null;
    newHostPricing = json["NewHostPricing"]!=null?List<HostPricing>.from(json["NewHostPricing"].map((x) => HostPricing.fromJson(x))):null;
    cancellationFee = json['CancellationFee'] != null
        ? new CancellationFee.fromJson(json['CancellationFee'])
        : null;
    bookingEventID = json['BookingEventID'];
    rBN = json['RBN'];
    bookingType = json['BookingType'];
    swapHostA = json['SwapHostA'] != null
        ? new SwapHostA.fromJson(json['SwapHostA'])
        : null;
    swapHostB = json['SwapHostB'] != null
        ? new SwapHostA.fromJson(json['SwapHostB'])
        : null;
    sBN = json['SBN'];
    bookingDate = json['BookingDate'];
    noOfTripRequests = json['NoOfTripRequests'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BookingID'] = this.bookingID;
    data['TripID'] = this.tripID;
    if (this.params != null) {
      data['Params'] = this.params!.toJson();
    }
    if (this.pricing != null) {
      data['Pricing'] = this.pricing!.toJson();
    }
    data['DeliveryDistance'] = this.deliveryDistance;
    data['BookingStatus'] = this.bookingStatus;
    data['Logs'] = this.logs;
    if (this.hostPricing != null) {
      data['HostPricing'] = this.hostPricing!.toJson();
    }
    if (this.cancellationFee != null) {
      data['CancellationFee'] = this.cancellationFee!.toJson();
    }
    data['BookingEventID'] = this.bookingEventID;
    data['RBN'] = this.rBN;
    data['BookingType'] = this.bookingType;
    if (this.swapHostA != null) {
      data['SwapHostA'] = this.swapHostA!.toJson();
    }
    if (this.swapHostB != null) {
      data['SwapHostB'] = this.swapHostB!.toJson();
    }
    data['SBN'] = this.sBN;
    data['BookingDate'] = this.bookingDate;
    return data;
  }
}

class Params {
  String? carID;
  String? startDateTime;
  String? endDateTime;
  List? newStartDateTime;
  List? newEndDateTime;
  PickupReturnLocation? pickupReturnLocation;
  List<ReturnLocation>? returnLocation;
  String? insuranceType;
  bool? deliveryNeeded;
  String? couponCode;
  String? userID;
  String? guestUserID;
  String? hostUserID;

  Params(
      {this.carID,
        this.startDateTime,
        this.endDateTime,
        this.newStartDateTime,
        this.newEndDateTime,
        this.pickupReturnLocation,
        this.returnLocation,
        this.insuranceType,
        this.deliveryNeeded,
        this.couponCode,
        this.userID,
        this.guestUserID,
        this.hostUserID});

  Params.fromJson(Map<String, dynamic> json) {
    carID = json['CarID'];
    startDateTime = json['StartDateTime'];
    endDateTime = json['EndDateTime'];
    newStartDateTime = json["NewStartDateTime"];
    newEndDateTime = json["NewEndDateTime"];
    pickupReturnLocation = json['PickupReturnLocation'] != null
        ? new PickupReturnLocation.fromJson(json['PickupReturnLocation'])
        : null;
    returnLocation = json['ReturnLocation'] != null?List<ReturnLocation>.from(json["ReturnLocation"].map((x) => ReturnLocation.fromJson(x))):null;
    insuranceType = json['InsuranceType'];
    deliveryNeeded = json['DeliveryNeeded'];
    couponCode = json['CouponCode'];
    userID = json['UserID'];
    guestUserID = json['GuestUserID'];
    hostUserID = json['HostUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CarID'] = this.carID;
    data['StartDateTime'] = this.startDateTime;
    data['EndDateTime'] = this.endDateTime;
    if (this.pickupReturnLocation != null) {
      data['PickupReturnLocation'] = this.pickupReturnLocation!.toJson();
    }
    data['InsuranceType'] = this.insuranceType;
    data['DeliveryNeeded'] = this.deliveryNeeded;
    data['CouponCode'] = this.couponCode;
    data['UserID'] = this.userID;
    data['GuestUserID'] = this.guestUserID;
    data['HostUserID'] = this.hostUserID;
    return data;
  }
}

class PickupReturnLocation {
  String? address;
  LatLng? latLng;

  PickupReturnLocation({this.address, this.latLng});

  PickupReturnLocation.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    latLng =
    json['LatLng'] != null ? new LatLng.fromJson(json['LatLng']) : null;
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
class ReturnLocation {
  String? address;
  LatLng? latLng;

  ReturnLocation({this.address, this.latLng});

  ReturnLocation.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    latLng =
    json['LatLng'] != null ? new LatLng.fromJson(json['LatLng']) : null;
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
    latitude = double.parse(json['Latitude'].toString());
    longitude =  double.parse(json['Longitude'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    return data;
  }
}

class Pricing {
  double? tripRate;
  String? tripRateUnit;
  double? tripPrice;
  double? deliveryFee;
  String? discountType;
  double? tripFee;
  double? discount;
  double? discountPercentage;
  double? total;
  double? ridealikeFee;
  double? tax;
  String? insuranceType;
  double? insuranceFee;
  double? ridealikeCoupon;
  bool? couponApplicable;
  bool? couponAvailed;
  String? freeCancelBeforeDateTime;
  String? tripDurationInString;
  String? deliveryRateInString;

  Pricing(
      {this.tripRate,
        this.tripRateUnit,
        this.tripPrice,
        this.deliveryFee,
        this.discountType,
        this.tripFee,
        this.discount,
        this.discountPercentage,
        this.total,
        this.ridealikeFee,
        this.tax,
        this.insuranceType,
        this.insuranceFee,
        this.ridealikeCoupon,
        this.couponApplicable,
        this.couponAvailed,
        this.freeCancelBeforeDateTime,
        this.tripDurationInString,
        this.deliveryRateInString});

  Pricing.fromJson(Map<String, dynamic> json) {
    tripRate =  double.parse(json['TripRate'].toString());
    tripRateUnit = json['TripRateUnit'];
    tripPrice =  double.parse(json['TripPrice'].toString());
    deliveryFee =  double.parse(json['DeliveryFee'].toString());
    discountType = json['DiscountType'];
    tripFee =  double.parse(json['TripFee'].toString());
    discount =  double.parse(json['Discount'].toString());
    discountPercentage = double.parse( json['DiscountPercentage'].toString());
    total =  double.parse(json['Total'].toString());
    ridealikeFee = double.parse(json['RidealikeFee'].toString());
    tax =  double.parse(json['Tax'].toString());
    insuranceType = json['InsuranceType'];
    insuranceFee =  double.parse(json['InsuranceFee'].toString());
    ridealikeCoupon =  double.parse(json['RidealikeCoupon'].toString());
    couponApplicable = json['CouponApplicable'];
    couponAvailed = json['CouponAvailed'];
    freeCancelBeforeDateTime = json['FreeCancelBeforeDateTime'];
    tripDurationInString = json['TripDurationInString'];
    deliveryRateInString = json['DeliveryRateInString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TripRate'] = this.tripRate;
    data['TripRateUnit'] = this.tripRateUnit;
    data['TripPrice'] = this.tripPrice;
    data['DeliveryFee'] = this.deliveryFee;
    data['DiscountType'] = this.discountType;
    data['TripFee'] = this.tripFee;
    data['Discount'] = this.discount;
    data['DiscountPercentage'] = this.discountPercentage;
    data['Total'] = this.total;
    data['RidealikeFee'] = this.ridealikeFee;
    data['Tax'] = this.tax;
    data['InsuranceType'] = this.insuranceType;
    data['InsuranceFee'] = this.insuranceFee;
    data['RidealikeCoupon'] = this.ridealikeCoupon;
    data['CouponApplicable'] = this.couponApplicable;
    data['CouponAvailed'] = this.couponAvailed;
    data['FreeCancelBeforeDateTime'] = this.freeCancelBeforeDateTime;
    data['TripDurationInString'] = this.tripDurationInString;
    data['DeliveryRateInString'] = this.deliveryRateInString;
    return data;
  }
}

class HostPricing {
  double? tripPrice;
  double? approvedDiscount;
  double? ridealikeFee;
  double? deliveryFee;
  double? total;
  String? tripDurationInString;

  HostPricing(
      {this.tripPrice,
        this.approvedDiscount,
        this.ridealikeFee,
        this.deliveryFee,
        this.total,
        this.tripDurationInString});

  HostPricing.fromJson(Map<String, dynamic> json) {
    tripPrice =  double.parse(json['TripPrice'].toString());
    approvedDiscount =  double.parse(json['ApprovedDiscount'].toString());
    ridealikeFee =  double.parse(json['RidealikeFee'].toString());
    deliveryFee =  double.parse(json['DeliveryFee'].toString());
    total = double.parse(json['Total'].toString()) ;
    tripDurationInString = json['TripDurationInString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TripPrice'] = this.tripPrice;
    data['ApprovedDiscount'] = this.approvedDiscount;
    data['RidealikeFee'] = this.ridealikeFee;
    data['DeliveryFee'] = this.deliveryFee;
    data['Total'] = this.total;
    data['TripDurationInString'] = this.tripDurationInString;
    return data;
  }
}

class CancellationFee {
  String? cancelledByUserID;
  String? whoCancelled;
  bool? freeCancellation;
  double? cancellationFee;
  double? total;
  String? cancelledDate;
  CancellationProfit? cancellationProfit;
  double? refund;
  double? hostARefund;
  double? hostBRefund;

  CancellationFee(
      {this.cancelledByUserID,
        this.whoCancelled,
        this.freeCancellation,
        this.cancellationFee,
        this.total,
        this.cancelledDate,
        this.cancellationProfit,
        this.refund,
        this.hostARefund,
        this.hostBRefund});

  CancellationFee.fromJson(Map<String, dynamic> json) {
    cancelledByUserID = json['CancelledByUserID'];
    whoCancelled = json['WhoCancelled'];
    freeCancellation = json['FreeCancellation'];
    cancellationFee =  double.parse(json['CancellationFee'].toString());
    total = double.parse(json['Total'].toString()) ;
    cancelledDate = json['CancelledDate'];
    cancellationProfit = json['CancellationProfit'] != null
        ? new CancellationProfit.fromJson(json['CancellationProfit'])
        : null;
    refund =  double.parse(json['Refund'].toString());
    hostARefund = double.parse(json['HostARefund'].toString()) ;
    hostBRefund =  double.parse(json['HostBRefund'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CancelledByUserID'] = this.cancelledByUserID;
    data['WhoCancelled'] = this.whoCancelled;
    data['FreeCancellation'] = this.freeCancellation;
    data['CancellationFee'] = this.cancellationFee;
    data['Total'] = this.total;
    data['CancelledDate'] = this.cancelledDate;
    if (this.cancellationProfit != null) {
      data['CancellationProfit'] = this.cancellationProfit!.toJson();
    }
    data['Refund'] = this.refund;
    data['HostARefund'] = this.hostARefund;
    data['HostBRefund'] = this.hostBRefund;
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
      {this.whoGained,
        this.whoProfittedUserID,
        this.whoPaid,
        this.whoPaidUserID,
        this.ammount,
        this.remarks});

  CancellationProfit.fromJson(Map<String, dynamic> json) {
    whoGained = json['WhoGained'];
    whoProfittedUserID = json['WhoProfittedUserID'];
    whoPaid = json['WhoPaid'];
    whoPaidUserID = json['WhoPaidUserID'];
    ammount =  double.parse(json['Ammount'].toString());
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

class SwapHostA {
  String? userID;
  String? myCarID;
  String? theirCarID;
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
  String? recievableRateString;
  String? payableRateString;

  SwapHostA(
      {this.userID,
        this.myCarID,
        this.theirCarID,
        this.recievable,
        this.payable,
        this.income,
        this.insuranceFee,
        this.ridealikeFee,
        this.discountPercentage,
        this.discount,
        this.ridealikeCoupon,
        this.cancellationFee,
        this.total,
        this.providedDiscount,
        this.recievableRateString,
        this.payableRateString});

  SwapHostA.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    myCarID = json['MyCarID'];
    theirCarID = json['TheirCarID'];
    recievable =  double.parse(json['Recievable'].toString());
    payable =  double.parse(json['Payable'].toString());
    income =  double.parse(json['income'].toString());
    insuranceFee =  double.parse(json['insuranceFee'].toString());
    ridealikeFee =  double.parse(json['RidealikeFee'].toString());
    discountPercentage = double.parse(json['DiscountPercentage'].toString()) ;
    discount =  double.parse(json['Discount'].toString());
    ridealikeCoupon =  double.parse(json['RidealikeCoupon'].toString());
    cancellationFee =  double.parse(json['CancellationFee'].toString());
    total =  double.parse(json['Total'].toString());
    providedDiscount =  double.parse(json['ProvidedDiscount'].toString());
    recievableRateString = json['RecievableRateString'];
    payableRateString = json['PayableRateString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserID'] = this.userID;
    data['MyCarID'] = this.myCarID;
    data['TheirCarID'] = this.theirCarID;
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
    data['RecievableRateString'] = this.recievableRateString;
    data['PayableRateString'] = this.payableRateString;
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