class CarBannerListResponse {
  List<ImageIDs>? imageIDs;
  Status? status;

  CarBannerListResponse({this.imageIDs, this.status});

  CarBannerListResponse.fromJson(Map<String, dynamic> json) {
    if (json['ImageIDs'] != null) {
      imageIDs = <ImageIDs>[];
      json['ImageIDs'].forEach((v) {
        imageIDs!.add(new ImageIDs.fromJson(v));
      });
    }
    status =
    (json['Status'] != null ? new Status.fromJson(json['Status']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.imageIDs != null) {
      data['ImageIDs'] = this.imageIDs!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class ImageIDs {
  String? title;
  String? subTitle;
  String? imageID;
  String? iD;

  ImageIDs({this.title, this.subTitle, this.imageID, this.iD});

  ImageIDs.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    subTitle = json['SubTitle'];
    imageID = json['ImageID'];
    iD = json['ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Title'] = this.title;
    data['SubTitle'] = this.subTitle;
    data['ImageID'] = this.imageID;
    data['ID'] = this.iD;
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
