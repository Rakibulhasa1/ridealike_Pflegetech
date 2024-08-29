class PaymentCardInfo {
  List<CardInfo>? cardInfo;
  Status? status;

  PaymentCardInfo({this.cardInfo, this.status});

  PaymentCardInfo.fromJson(Map<String, dynamic> json) {
    if (json['CardInfo'] != null) {
      // cardInfo = new List<CardInfo>();
      cardInfo = <CardInfo>[];
      json['CardInfo'].forEach((v) {
        cardInfo!.add(new CardInfo.fromJson(v));
      });
    }
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cardInfo != null) {
      data['CardInfo'] = this.cardInfo!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class CardInfo {
  String? cardID;
  String? lastFourDigits;
  String? userID;
  String? createdAt;
  String? updatedAt;

  CardInfo(
      {this.cardID,
        this.lastFourDigits,
        this.userID,
        this.createdAt,
        this.updatedAt});

  CardInfo.fromJson(Map<String, dynamic> json) {
    cardID = json['CardID'];
    lastFourDigits = json['LastFourDigits'];
    userID = json['UserID'];
    createdAt = json['CreatedAt'];
    updatedAt = json['UpdatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CardID'] = this.cardID;
    data['LastFourDigits'] = this.lastFourDigits;
    data['UserID'] = this.userID;
    data['CreatedAt'] = this.createdAt;
    data['UpdatedAt'] = this.updatedAt;
    return data;
  }
}

class Status {
  bool? success;
  String? error;

  Status({this.success, this.error});

  Status.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    error = json['Error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Success'] = this.success;
    data['Error'] = this.error;
    return data;
  }
}