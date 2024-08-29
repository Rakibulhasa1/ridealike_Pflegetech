class RateTripHostRequest {
  String? tripID;
 String? rateHost;
  String? reviewHostDescription;
  String? inspectionByUserID;

  RateTripHostRequest(
      {this.tripID,
       required this.rateHost,
        this.reviewHostDescription,
        this.inspectionByUserID});

  RateTripHostRequest.fromJson(Map<String, dynamic> json) {
    tripID = json['TripID'];
    rateHost = json['RateHost'];
    reviewHostDescription = json['ReviewHostDescription'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TripID'] = this.tripID;
    data['RateHost'] = double.parse(this.rateHost!).floor().toString();
    data['ReviewHostDescription'] = this.reviewHostDescription;
    data['InspectionByUserID'] = this.inspectionByUserID;
    return data;
  }
}
