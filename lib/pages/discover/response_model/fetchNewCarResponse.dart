class FetchNewCarResponse {
  List<Cars>? cars;
  Status? status;
  Latlng? latlng; // not from response

  FetchNewCarResponse({this.cars, this.status});

  FetchNewCarResponse.fromJson(Map<String, dynamic> json) {
    cars = (json['cars'] as List<dynamic>?)
        ?.map((v) => Cars.fromJson(v as Map<String, dynamic>))
        .toList();
    status = json['status'] != null ? Status.fromJson(json['status']!) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cars != null) {
      data['cars'] = cars!.map((v) => v.toJson()).toList();
    }
    if (status != null) {
      data['status'] = status!.toJson();
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

  Cars({
    this.id,
    this.userId,
    this.title,
    this.year,
    this.numberOfTrips,
    this.price,
    this.rating,
    this.imageId,
    this.latlng,
    this.createdAt,
    this.updatedAt,
  });

  Cars.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    userId = json['user_id'] as String?;
    title = json['title'] as String?;
    year = json['year'] as String?;
    numberOfTrips = json['number_of_trips'] as String?;
    price = json['price'] as String?;
    rating = double.parse(json['rating']!.toString());
    imageId = json['image_id'] as String?;
    latlng = json['latlng'] != null ? Latlng.fromJson(json['latlng']!) : null;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['title'] = title;
    data['year'] = year;
    data['number_of_trips'] = numberOfTrips;
    data['price'] = price;
    data['rating'] = rating;
    data['image_id'] = imageId;
    if (latlng != null) {
      data['latlng'] = latlng!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Latlng {
  double? latitude;
  double? longitude;

  Latlng({this.latitude, this.longitude});

  Latlng.fromJson(Map<String, dynamic> json) {
    latitude = double.parse(json['latitude']!.toString());
    longitude = double.parse(json['longitude']!.toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class Status {
  bool? success;
  String? error;

  Status({this.success, this.error});

  Status.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    error = json['error'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['error'] = error;
    return data;
  }
}
