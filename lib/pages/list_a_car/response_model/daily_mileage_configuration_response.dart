class FetchDailyMileageConfigurationResponse {
  ListCarConfigurables? listCarConfigurables;
  Status? status;

  FetchDailyMileageConfigurationResponse(
      {this.listCarConfigurables, this.status});

  FetchDailyMileageConfigurationResponse.fromJson(Map<String, dynamic> json) {
    listCarConfigurables = json['ListCarConfigurables'] != null
        ? new ListCarConfigurables.fromJson(json['ListCarConfigurables'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listCarConfigurables != null) {
      data['ListCarConfigurables'] = this.listCarConfigurables!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class ListCarConfigurables {
  DailyMileageAllowanceLimitRange? dailyMileageAllowanceLimitRange;
  int? swapWithinMaxLimit;

  ListCarConfigurables(
      {this.dailyMileageAllowanceLimitRange, this.swapWithinMaxLimit});

  ListCarConfigurables.fromJson(Map<String, dynamic> json) {
    dailyMileageAllowanceLimitRange =
    json['DailyMileageAllowanceLimitRange'] != null
        ? new DailyMileageAllowanceLimitRange.fromJson(
        json['DailyMileageAllowanceLimitRange'])
        : null;
    swapWithinMaxLimit = json['SwapWithinMaxLimit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dailyMileageAllowanceLimitRange != null) {
      data['DailyMileageAllowanceLimitRange'] =
          this.dailyMileageAllowanceLimitRange!.toJson();
    }
    data['SwapWithinMaxLimit'] = this.swapWithinMaxLimit;
    return data;
  }
}

class DailyMileageAllowanceLimitRange {
  int? min;
  int? max;

  DailyMileageAllowanceLimitRange({this.min, this.max});

  DailyMileageAllowanceLimitRange.fromJson(Map<String, dynamic> json) {
    min = json['Min'];
    max = json['Max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Min'] = this.min;
    data['Max'] = this.max;
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
