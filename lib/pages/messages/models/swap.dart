import 'package:ridealike/pages/messages//enums/swaptype.dart';

class Swap {
  String? header;
  String agreementId;
  String userId;
  String? title;
  String? vehicle;
  String? message;
  String? startDate;
  String? endDate;
  SwapType? type;
  String? address;
  String? myAddress;
  String? payout;
  String? fee;
  String? status;
  String? suggestedByUserID;
  double? lat;
  double? lon;
  double? myLat;
  double? myLon;
  String? insurance;
  double? total;
  String? tripStatus;
  String? tripId;
  bool? load;
  String? userVerificationStatus;

  Swap({
    required this.agreementId,
    required this.userId,
    this.userVerificationStatus,
    this.load
  });

}
