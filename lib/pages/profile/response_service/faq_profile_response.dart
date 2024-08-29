class FaqProfileResponse {
  List<FAQ>? fAQ;
  Status? status;

  FaqProfileResponse({ this.fAQ,  this.status});

  FaqProfileResponse.fromJson(Map<String, dynamic> json) {
    if (json['FAQ'] != null) {
      // fAQ = new List<FAQ>();
      fAQ = [];
      json['FAQ'].forEach((v) {
        fAQ!.add(new FAQ.fromJson(v));
      });
    }
    status =
    json['Status'] != null ? new Status.fromJson(json['Status']) : null!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fAQ != null) {
      data['FAQ'] = this.fAQ!.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['Status'] = this.status!.toJson();
    }
    return data;
  }
}

class FAQ {
  String? iD;
  String? question;
  String? explanation;
  String? fAQType;

  FAQ({this.iD, this.question, this.explanation, this.fAQType});

  FAQ.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    question = json['Question'];
    explanation = json['Explanation'];
    fAQType = json['FAQType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['Question'] = this.question;
    data['Explanation'] = this.explanation;
    data['FAQType'] = this.fAQType;
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