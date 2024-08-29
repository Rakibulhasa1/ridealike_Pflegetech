class SearchCarMakeResponse {
  List<CarMakes>? carMakes;
  Status? status;

  SearchCarMakeResponse({this.carMakes, this.status});

  SearchCarMakeResponse.fromJson(Map<String, dynamic> json) {
    if (json['CarMakes'] != null) {
      // carMakes = new List<CarMakes>();
      carMakes = <CarMakes>[];
      json['CarMakes'].forEach((v) {
        carMakes!.add(new CarMakes.fromJson(v));
      });
    }
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.carMakes != null) {
      data['CarMakes'] = this.carMakes!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class CarMakes {
  String? makeID;
  String? name;
  String? logoID;
  bool selected = false;

  CarMakes({this.makeID, this.name, this.logoID});

  CarMakes.fromJson(Map<String, dynamic> json) {
    makeID = json['MakeID'];
    name = json['Name'];
    logoID = json['LogoID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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