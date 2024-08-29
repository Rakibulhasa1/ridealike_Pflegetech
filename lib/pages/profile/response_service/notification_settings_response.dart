class NotificationSettingsResponse {
  NotificationSetting? notificationSetting;
  Status? status;

  NotificationSettingsResponse({this.notificationSetting, this.status});

  NotificationSettingsResponse.fromJson(Map<String, dynamic> json) {
    notificationSetting = json['NotificationSetting'] != null
        ? new NotificationSetting.fromJson(json['NotificationSetting'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notificationSetting != null) {
      data['NotificationSetting'] = this.notificationSetting!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class NotificationSetting {
  String? userID;
  Messages? messages;
  Messages? reminders;
  Messages? productsPromotions;
  Messages? profileSupport;

  NotificationSetting(
      {this.userID,
        this.messages,
        this.reminders,
        this.productsPromotions,
        this.profileSupport});

  NotificationSetting.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    messages = json['Messages'] != null
        ? new Messages.fromJson(json['Messages'])
        : null;
    reminders = json['Reminders'] != null
        ? new Messages.fromJson(json['Reminders'])
        : null;
    productsPromotions = json['ProductsPromotions'] != null
        ? new Messages.fromJson(json['ProductsPromotions'])
        : null;
    profileSupport = json['ProfileSupport'] != null
        ? new Messages.fromJson(json['ProfileSupport'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserID'] = this.userID;
    if (this.messages != null) {
      data['Messages'] = this.messages!.toJson();
    }
    if (this.reminders != null) {
      data['Reminders'] = this.reminders!.toJson();
    }
    if (this.productsPromotions != null) {
      data['ProductsPromotions'] = this.productsPromotions!.toJson();
    }
    if (this.profileSupport != null) {
      data['ProfileSupport'] = this.profileSupport!.toJson();
    }
    return data;
  }
}

class Messages {
  bool? push;
  bool? email;
  bool? text;

  Messages({this.push, this.email, this.text});

  Messages.fromJson(Map<String, dynamic> json) {
    push = json['Push'];
    email = json['Email'];
    text = json['Text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Push'] = this.push;
    data['Email'] = this.email;
    data['Text'] = this.text;
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