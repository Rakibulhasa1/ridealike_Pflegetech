class RateTripGuestRequest {
  String? rateGuest;
  String? reviewGuestDescription;
  String? tripID;
  String? inspectionByUserID;

  RateTripGuestRequest(
      {required this.rateGuest,
        this.reviewGuestDescription,
        this.tripID,
        this.inspectionByUserID});

  RateTripGuestRequest.fromJson(Map<String, dynamic> json) {
    rateGuest = json['RateGuest'];
    reviewGuestDescription = json['ReviewGuestDescription'];
    tripID = json['TripID'];
    inspectionByUserID = json['InspectionByUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RateGuest'] = double.parse(this.rateGuest!).floor().toString();
    data['ReviewGuestDescription'] = this.reviewGuestDescription;
    data['TripID'] = this.tripID;
    data['InspectionByUserID'] = this.inspectionByUserID;
    return data;
  }
}
