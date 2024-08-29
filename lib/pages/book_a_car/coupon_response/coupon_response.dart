class Coupon {
  String id;
  String couponName;
  String couponCode;
  int amount;
  int numberOfDaysDiscount;
  int percentageDiscount;
  int maximumNumberOfCoupons;
  int rentalDaysRequired;
  int rentalAmountRequired;
  int maxAmountDiscount;
  String greenFeature;
  DateTime validFrom;
  DateTime validTill;
  int totalUsed;
  bool multipleUse;
  String usageNumber;
  bool userCoupon;
  bool carCoupon;
  String carId;
  String userId;

  Coupon({
    required this.id,
    required this.couponName,
    required this.couponCode,
    required this.amount,
    required this.numberOfDaysDiscount,
    required this.percentageDiscount,
    required this.maximumNumberOfCoupons,
    required this.rentalDaysRequired,
    required this.rentalAmountRequired,
    required this.maxAmountDiscount,
    required this.greenFeature,
    required this.validFrom,
    required this.validTill,
    required this.totalUsed,
    required this.multipleUse,
    required this.usageNumber,
    required this.userCoupon,
    required this.carCoupon,
    required this.carId,
    required this.userId,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['ID'],
      couponName: json['CouponName'],
      couponCode: json['CouponCode'],
      amount: json['Amount'],
      numberOfDaysDiscount: json['NumberOfDaysDiscount'],
      percentageDiscount: json['PercentageDiscount'],
      maximumNumberOfCoupons: json['MaximumNumberOfCoupons'],
      rentalDaysRequired: json['RentalDaysRequired'],
      rentalAmountRequired: json['RentalAmountRequired'],
      maxAmountDiscount: json['MaxAmountDiscount'],
      greenFeature: json['GreenFeature'],
      validFrom: DateTime.parse(json['ValidFrom']),
      validTill: DateTime.parse(json['ValidTill']),
      totalUsed: json['TotalUsed'],
      multipleUse: json['MultipleUse'],
      usageNumber: json['UsageNumber'],
      userCoupon: json['UserCoupon'],
      carCoupon: json['CarCoupon'],
      carId: json['CarID'],
      userId: json['UserID'],
    );
  }

  @override
  String toString() {
    return 'Coupon{id: $id, couponName: $couponName, couponCode: $couponCode, amount: $amount, numberOfDaysDiscount: $numberOfDaysDiscount, percentageDiscount: $percentageDiscount, maximumNumberOfCoupons: $maximumNumberOfCoupons, rentalDaysRequired: $rentalDaysRequired, rentalAmountRequired: $rentalAmountRequired, maxAmountDiscount: $maxAmountDiscount, greenFeature: $greenFeature, validFrom: $validFrom, validTill: $validTill, totalUsed: $totalUsed, multipleUse: $multipleUse, usageNumber: $usageNumber, userCoupon: $userCoupon, carCoupon: $carCoupon, carId: $carId, userId: $userId}';
  }
}

class Status {
  bool success;
  String error;

  Status({required this.success, required this.error});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      success: json['success'],
      error: json['error'],
    );
  }
}

class ApiResponse {
  List<Coupon> coupons;
  Status status;

  ApiResponse({required this.coupons, required this.status});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['Coupon'] as List;
    List<Coupon> couponList = list.map((i) => Coupon.fromJson(i)).toList();
    return ApiResponse(
      coupons: couponList,
      status: Status.fromJson(json['Status']),
    );
  }
}
