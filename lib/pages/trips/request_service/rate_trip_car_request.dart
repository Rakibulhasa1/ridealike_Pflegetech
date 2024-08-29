class RateTripCarRequest {
  String? tripID;
  String? rateCar;
  String? reviewCarDescription;
  String? inspectionByUserID;

  RateTripCarRequest(
      {this.tripID,
       required this.rateCar,
        this.reviewCarDescription,
        this.inspectionByUserID});

  RateTripCarRequest.fromJson(Map<String, dynamic> json) {
    tripID = json['TripID'];
    rateCar = json['RateCar'];
    reviewCarDescription = json['ReviewCarDescription'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TripID'] = this.tripID;
    data['RateCar'] = double.parse(this.rateCar!).floor().toString();
    data['ReviewCarDescription'] = this.reviewCarDescription;
    data['InspectionByUserID'] = this.inspectionByUserID;
    return data;
  }
}
