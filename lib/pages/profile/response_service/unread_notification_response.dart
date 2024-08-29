class UnreadNotificationResponse {
  List<Notification>? notification;
  Status? status;
  int? skip;
  int? limit;
  String? totalCount;

  UnreadNotificationResponse(
      {this.notification, this.status, this.skip, this.limit, this.totalCount});

  UnreadNotificationResponse.fromJson(Map<String, dynamic> json) {
    if (json['Notification'] != null) {
      // notification = new List<Notification>();
      notification = <Notification>[];
      json['Notification'].forEach((v) {
        notification!.add(new Notification.fromJson(v));
      });
    }
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
    skip = json['Skip'];
    limit = json['Limit'];
    totalCount = json['TotalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notification != null) {
      data['Notification'] = this.notification!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    data['Skip'] = this.skip;
    data['Limit'] = this.limit;
    data['TotalCount'] = this.totalCount;
    return data;
  }
}

class Notification {
  String? userID;
  String? notificationID;
  String? title;
  String? body;
  String? dateTime;
  String? notificationType;
  String? readStatus;

  Notification(
      {this.userID,
        this.notificationID,
        this.title,
        this.body,
        this.dateTime,
        this.notificationType,
        this.readStatus});

  Notification.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    notificationID = json['NotificationID'];
    title = json['Title'];
    body = json['Body'];
    dateTime = json['DateTime'];
    notificationType = json['NotificationType'];
    readStatus = json['ReadStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserID'] = this.userID;
    data['NotificationID'] = this.notificationID;
    data['Title'] = this.title;
    data['Body'] = this.body;
    data['DateTime'] = this.dateTime;
    data['NotificationType'] = this.notificationType;
    data['ReadStatus'] = this.readStatus;
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