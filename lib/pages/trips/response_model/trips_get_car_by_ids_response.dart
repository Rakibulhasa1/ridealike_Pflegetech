import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

class GetCarsByCarIDsResponse {
  List<Car>? cars;
  Status? status;

  GetCarsByCarIDsResponse({this.cars, this.status});

  GetCarsByCarIDsResponse.fromJson(Map<String, dynamic> json) {
    if (json['Cars'] != null) {
      cars = <Car>[];

      json['Cars'].forEach((v) {
        cars!.add(Car.fromJson(v));
      });
    }
    status = json['Status'] != null ? Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.cars != null) {
      data['Cars'] = this.cars!.map((v) => v.toJson()).toList();
    }
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = this.success;
    data['error'] = this.error;
    return data;
  }
}
