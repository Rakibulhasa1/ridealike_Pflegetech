class OptionsList {
   List<HeardOptions>? heardOptions;
   String? selectedValue;
   String? othersValue;
   Status? status;

  OptionsList({ this.heardOptions,  this.status});

  OptionsList.fromJson(Map<String, dynamic> json) {
    if (json['HeardOptions'] != null) {
      heardOptions =  <HeardOptions>[];
      json['HeardOptions'].forEach((v) {
        heardOptions!.add(new HeardOptions.fromJson(v));
      });
    }
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.heardOptions != null) {
      data['HeardOptions'] = this.heardOptions!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class HeardOptions {
  String? iD;
  String? optionName;

  HeardOptions({this.iD, this.optionName});

  HeardOptions.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    optionName = json['OptionName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['OptionName'] = this.optionName;
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