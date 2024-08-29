class FetchPopularCarResponse {
  List<Cars>? cars;
  Status? status;

  FetchPopularCarResponse({this.cars, this.status});

  FetchPopularCarResponse.fromJson(Map<String, dynamic> json) {
    if (json['cars'] != null) {
      cars =  <Cars>[];
      json['cars'].forEach((v) {
        cars!.add(new Cars.fromJson(v));
      });
    }
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cars != null) {
      data['cars'] = this.cars!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class Cars {
  String? id;
  String? userId;
  String? title;
  String? year;
  String? numberOfTrips;
  String? price;
  double? rating;
  String? imageId;
  Latlng? latlng;
  String? createdAt;
  String? updatedAt;

  Cars(
      {this.id,
        this.userId,
        this.title,
        this.year,
        this.numberOfTrips,
        this.price,
        this.rating,
        this.imageId,
        this.latlng,
        this.createdAt,
        this.updatedAt});

  Cars.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    year = json['year'];
    numberOfTrips = json['number_of_trips'];
    price = json['price'];
    rating = double.parse(json['rating'].toString());
    imageId = json['image_id'];
    latlng =
    json['latlng'] != null ? new Latlng.fromJson(json['latlng']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['year'] = this.year;
    data['number_of_trips'] = this.numberOfTrips;
    data['price'] = this.price;
    data['rating'] = this.rating;
    data['image_id'] = this.imageId;
    if (this.latlng != null) {
      data['latlng'] = this.latlng!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Latlng {
  double? latitude;
  double? longitude;

  Latlng({this.latitude, this.longitude});

  Latlng.fromJson(Map<String, dynamic> json) {
    latitude = double.parse(json['latitude'].toString());
    longitude = double.parse(json['longitude'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
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