class SwapCalendarEventsResponse {
  SwapCalendar? calendarA;
  SwapCalendar? calendarB;
  Status? status;

  SwapCalendarEventsResponse({this.calendarA, this.calendarB, this.status});

  SwapCalendarEventsResponse.fromJson(Map<String, dynamic> json) {
    calendarA = json['CalendarA'] != null
        ? new SwapCalendar.fromJson(json['CalendarA'])
        : null;
    calendarB = json['CalendarB'] != null
        ? new SwapCalendar.fromJson(json['CalendarB'])
        : null;
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.calendarA != null) {
      data['CalendarA'] = this.calendarA!.toJson();
    }
    if (this.calendarB != null) {
      data['CalendarB'] = this.calendarB!.toJson();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class SwapCalendar {
  String? id;
  String? summary;
  String? ownerId;
  List<CalendarEvents>? events;

  SwapCalendar({this.id, this.summary, this.ownerId, this.events});

  SwapCalendar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    summary = json['summary'];
    ownerId = json['owner_id'];
    // if (json['events'] != null) {
    //   events = new List<CalendarEvents>();
    //   json['events'].forEach((v) {
    //     events!.add(new CalendarEvents.fromJson(v));
    //   });
    // }
    events = (json['events'] as List<dynamic>?)
        ?.map((v) => CalendarEvents.fromJson(v))
        .toList();

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

class CalendarEvents {
  String? id;
  CalendarEvent? event;
  String? created;
  String? updated;
  String? calendarId;

  CalendarEvents({this.id, this.event, this.created, this.updated, this.calendarId});

  CalendarEvents.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    event = json['event'] != null ? new CalendarEvent.fromJson(json['event']) : null;
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

class CalendarEvent {
  String? creator;
  String? summary;
  String? description;
  String? startDatetime;
  String? endDatetime;
  String? status;

  CalendarEvent(
      {this.creator,
        this.summary,
        this.description,
        this.startDatetime,
        this.endDatetime,
        this.status});

  CalendarEvent.fromJson(Map<String, dynamic> json) {
    creator = json['creator'];
    summary = json['summary'];
    description = json['description'];
    startDatetime = json['start_datetime'];
    endDatetime = json['end_datetime'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['creator'] = this.creator;
    data['summary'] = this.summary;
    data['description'] = this.description;
    data['start_datetime'] = this.startDatetime;
    data['end_datetime'] = this.endDatetime;
    data['status'] = this.status;
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
