class SearchCarModelResponse {
  List<CarModels>? carModels;
  Status? status;

  SearchCarModelResponse({this.carModels, this.status});

  SearchCarModelResponse.fromJson(Map<String, dynamic> json) {
    if (json['CarModels'] != null) {
      // carModels = new List<CarModels>();
      carModels = <CarModels>[];
      json['CarModels'].forEach((v) {
        carModels!.add(new CarModels.fromJson(v));
      });
    }
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.carModels != null) {
      data['CarModels'] = this.carModels!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class CarModels {
  String? modelID;
  String? makeID;
  String? name;
  String? logoID;
  bool selected=false;

  CarModels({this.modelID, this.makeID, this.name, this.logoID});

  CarModels.fromJson(Map<String, dynamic> json) {
    modelID = json['ModelID'];
    makeID = json['MakeID'];
    name = json['Name'];
    logoID = json['LogoID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ModelID'] = this.modelID;
    data['MakeID'] = this.makeID;
    data['Name'] = this.name;
    data['LogoID'] = this.logoID;
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