class FetchCarSuggestedDataResponse {
  double? dailyRate;
  double? hourlyRate;
  double? everyExtraKMOver200KM;
  double? perKMDeliveryFee;
  double? weeklyDiscountPercentage;
  double? monthlyDiscountPercentage;
  Status? status;

  FetchCarSuggestedDataResponse(
      {this.dailyRate,
        this.hourlyRate,
        this.everyExtraKMOver200KM,
        this.perKMDeliveryFee,
        this.weeklyDiscountPercentage,
        this.monthlyDiscountPercentage,
        this.status});

  FetchCarSuggestedDataResponse.fromJson(Map<String, dynamic> json) {
    dailyRate = json['DailyRate'].toDouble();
    hourlyRate = json['HourlyRate'].toDouble();
    everyExtraKMOver200KM = json['EveryExtraKMOver200KM'].toDouble();
    perKMDeliveryFee = json['PerKMDeliveryFee'].toDouble();
    weeklyDiscountPercentage = json['WeeklyDiscountPercentage'].toDouble();
    monthlyDiscountPercentage = json['MonthlyDiscountPercentage'].toDouble();
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DailyRate'] = this.dailyRate;
    data['HourlyRate'] = this.hourlyRate;
    data['EveryExtraKMOver200KM'] = this.everyExtraKMOver200KM;
    data['PerKMDeliveryFee'] = this.perKMDeliveryFee;
    data['WeeklyDiscountPercentage'] = this.weeklyDiscountPercentage;
    data['MonthlyDiscountPercentage'] = this.monthlyDiscountPercentage;
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
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
