class ProfileNotification {
  List<Notification>? notification;
  Status? status;
  int? skip;
  int? limit;
  String? totalCount;

  ProfileNotification(
      {this.notification, this.status, this.skip, this.limit, this.totalCount});

  ProfileNotification.fromJson(Map<String, dynamic> json) {
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
  String? tripID;
  DateTime? dateTime;
  String? notificationType;
  String? rUserID;
  String? readStatus;
  Notification(
      {this.userID,
        this.notificationID,
        this.title,
        this.body,
        this.tripID,
        this.dateTime,
        this.notificationType,this.rUserID,this.readStatus});

  Notification.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    notificationID = json['NotificationID'];
    title = json['Title'];
    body = json['Body'];
    tripID = json['TripID'];
    dateTime = DateTime.parse(json['DateTime']);
    notificationType = json['NotificationType'];
    rUserID=json['RUserID'];
    readStatus = json['ReadStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserID'] = this.userID;
    data['NotificationID'] = this.notificationID;
    data['Title'] = this.title;
    data['Body'] = this.body;
    data['TripID'] = this.tripID;
    data['DateTime'] = this.dateTime;
    data['NotificationType'] = this.notificationType;
    data['RUserID']=this.rUserID;
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