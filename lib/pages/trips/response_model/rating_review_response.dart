class RatingReviewsResponse {
  List<RatingReviews>? ratingReviews;
  String? totalReviewCount;

  RatingReviewsResponse({this.ratingReviews, this.totalReviewCount});

  RatingReviewsResponse.fromJson(Map<String, dynamic> json) {
    if (json['RatingReviews'] != null) {
      // ratingReviews =  List<RatingReviews>();
      ratingReviews = [];

      json['RatingReviews'].forEach((v) {
        ratingReviews!.add(new RatingReviews.fromJson(v));
      });
    }
    totalReviewCount = json['TotalReviewCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ratingReviews != null) {
      data['RatingReviews'] =
          this.ratingReviews!.map((v) => v.toJson()).toList();
    }
    data['TotalReviewCount'] = this.totalReviewCount;
    return data;
  }
}

class RatingReviews {
  String? profileID;
  String? userID;
  String? rating;
  String? review;
  String? dateTime;
  String? reviewerUserID;

  RatingReviews(
      {this.profileID,
        this.userID,
        this.rating,
        this.review,
        this.dateTime,
        this.reviewerUserID});

  RatingReviews.fromJson(Map<String, dynamic> json) {
    profileID = json['ProfileID'];
    userID = json['UserID'];
    rating = json['Rating'];
    review = json['Review'];
    dateTime = json['DateTime'];
    reviewerUserID = json['ReviewerUserID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProfileID'] = this.profileID;
    data['UserID'] = this.userID;
    data['Rating'] = this.rating;
    data['Review'] = this.review;
    data['DateTime'] = this.dateTime;
    data['ReviewerUserID'] = this.reviewerUserID;
    return data;
  }
}
