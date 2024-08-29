class GetCalendarResponse {
  Calendar? calendar;
  Status? status;

  GetCalendarResponse({this.calendar, this.status});

  GetCalendarResponse.fromJson(Map<String, dynamic> json) {
    calendar = json['calendar'] != null
        ? new Calendar.fromJson(json['calendar'])
        : null;
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.calendar != null) {
      data['calendar'] = this.calendar!.toJson();
    }
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class Calendar {
  String? id;
  String? summary;
  String? ownerId;
  List<Events>? events;

  Calendar({this.id, this.summary, this.ownerId, this.events});

  Calendar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    summary = json['summary'];
    ownerId = json['owner_id'];
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(new Events.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['summary'] = this.summary;
    data['owner_id'] = this.ownerId;
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Events {
  String? id;
  Event? event;
  String? created;
  String? updated;
  String? calendarId;

  Events({this.id, this.event, this.created, this.updated, this.calendarId});

  Events.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    event = json['event'] != null ? new Event.fromJson(json['event']) : null;
    created = json['created'];
    updated = json['updated'];
    calendarId = json['calendar_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.event != null) {
      data['event'] = this.event!.toJson();
    }
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['calendar_id'] = this.calendarId;
    return data;
  }
}

class Event {
  String? creator;
  String? summary;
  String? description;
  String? startDatetime;
  String? endDatetime;

  Event(
      {this.creator,
        this.summary,
        this.description,
        this.startDatetime,
        this.endDatetime});

  Event.fromJson(Map<String, dynamic> json) {
    creator = json['creator'];
    summary = json['summary'];
    description = json['description'];
    startDatetime = json['start_datetime'];
    endDatetime = json['end_datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['creator'] = this.creator;
    data['summary'] = this.summary;
    data['description'] = this.description;
    data['start_datetime'] = this.startDatetime;
    data['end_datetime'] = this.endDatetime;
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
