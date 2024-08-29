import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/events/loadEvent.dart';
import 'package:ridealike/pages/messages/models/swap.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/messages/widgets/add_card_swap.dart';
import 'package:ridealike/pages/profile/response_service/payment_card_info.dart';

class SwapController extends ControllerMVC {
  Swap? swap;
  VoidCallback? onClicked;
  String userId = "";
  final storage = new FlutterSecureStorage();
  final oCcy = NumberFormat("#,##0.00", "en_US");
  ProgressDialog? pr;

  @override
  void initState() {
    super.initState();
    setUserID();
  }

  setUserID() async {
    userId = (await storage.read(key: 'user_id'))!;
  }

  Future<Swap?> getCardData() async {
    try {
      var data = {
        "SwapAgreementID": swap!.agreementId.toString(),
        "UserID": await storage.read(key: 'user_id'),
      };
      print(data);
      final response = await HttpClient.post(getSwapArgeementTermsUrl, data,
          token: await storage.read(key: 'jwt')as String);
      var status = response["Status"];
      print(response.toString());
      if (status["success"]) {
        var swapData = response["SwapAgreementTerms"];
        swap!.title = swap!.userVerificationStatus=="Undefined"?"Deleted Car": swapData["TheirCar"]["About"]["Year"].toString() +
            " " +
            swapData["TheirCar"]["About"]["Make"].toString() +
            " " +
            swapData["TheirCar"]["About"]["Model"].toString() +
            " " +
            swapData["TheirCar"]["About"]["CarBodyTrim"].toString() +
            " " +
            swapData["TheirCar"]["About"]["Style"].toString();
        swap!.message = "Swapping with your " + swapData["MyCarTitle"];
        swap!.startDate = swapData["StartDateTime"];
        swap!.endDate = swapData["EndDateTime"];
        swap!.status = swapData["SwapAgreementStatus"];
        swap!.address = swapData["Location"]["Address"];
        swap!.payout = swapData["TripPayout"].toString();
        swap!.fee = swapData["TripFee"].toString();
        swap!.suggestedByUserID = swapData["SuggestedByUserID"];
        String theirCarId = swapData["TheirCar"]["ID"];
        var carAPricing = swapData["PricingForCarAOwner"];
        var carBPricing = swapData["PricingForCarBOwner"];
        var carAInsurance = swapData["CarAInsurance"];
        var carBInsurance = swapData["CarBInsurance"];
        if (theirCarId == carAInsurance["carID"]) {
          swap!.insurance = carBInsurance["InsuranceType"];
          swap!.total = double.parse(carBPricing["Total"].toString());
        } else if (theirCarId == carBInsurance["carID"]) {
          swap!.insurance = carAInsurance["InsuranceType"];
          swap!.total = double.parse(carAPricing["Total"].toString());
        } else {
          swap!.insurance = "";
        }
        var locData = swapData["Location"]["LatLng"];
        swap!.lat = double.parse(locData["Latitude"].toString());
        swap!.lon = double.parse(locData["Longitude"].toString());
        var myCarData = swapData["MyCar"]["About"]["Location"];
        swap!.myLat = double.parse(myCarData["LatLng"]["Latitude"].toString());
        swap!.myLon = double.parse(myCarData["LatLng"]["Longitude"].toString());
        swap!.myAddress = myCarData["Address"];
      }
      //SWAP OPPORTUNITY
      print(":::status:::" + swap!.status!);
      String swapStatus = await getSwapStatus();
      print(":::swapstatus:::" + swapStatus);
      if (swap!.status == "Agreed") {
        String swapStatus = await getSwapStatus();
        swap!.tripStatus = swapStatus;
        print(":::swapstatus:::" + swapStatus);
        if (swapStatus == "Booked") {
          swap!.header = "UPCOMING SWAP";
        } else if (swapStatus == "Started") {
          swap!.header = "CURRENT SWAP";
        } else if (swapStatus == "Ended" || swapStatus == "Completed") {
          swap!.header = "PAST SWAP";
        } else if (swapStatus == "Cancelled") {
          swap!.header = "CANCELLED SWAP";
        } else {
          swap!.header = "SWAP OPPORTUNITY";
        }
      } else {
        swap!.header = "SWAP OPPORTUNITY";
      }
      return swap;
    } catch (e) {
      print(e);
      return null;
    } finally {
      if (swap!.load != null && swap!.load == true)
        print(":::::::::::::::::::load::::::::::::::::::::::");
      EventBusUtils.getInstance().fire(LoadEvent());
    }
  }

  Future<String> getSwapStatus() async {
    String swapStatus = "";
    try {
      var data = {"SwapAgreementID": swap!.agreementId.toString()};
      print(data);
      final response = await HttpClient.post(getAgreedSwapTripsStatusUrl, data,
          token: await storage.read(key: 'jwt') as String);
      var status = response["Status"];
      if (status["success"]) {
        List statusData = response["AgreedSwapTripStatuses"];
        if (statusData.length > 1) {
          if (statusData[0]["GuestUserID"] == userId) {
            swapStatus = statusData[0]["TripStatus"];
            swap!.tripId = statusData[0]["TripID"];
          } else {
            swapStatus = statusData[1]["TripStatus"];
            swap!.tripId = statusData[1]["TripID"];
          }
          print(swapStatus + ":::" + swap!.title!);
        }
      }
      return swapStatus;
    } catch (e) {
      print(e);
      return swapStatus;
    }
  }

  Future<bool> handleShowAddCardModal(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return AddCardSwap();
      },
    );
    bool hasCard = await fetchCardInfo(context);
    return hasCard;
  }

  Future<bool> fetchCardInfo(BuildContext context) async {
    try {
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.normal,
      );
      pr!.style(
        message: "Please wait...",
        progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
      await pr!.show();
      var data = {"UserID": userId};
      final response = await HttpClient.post(getCardsByUserIDUrl, data,
          token: await storage.read(key: 'jwt') as String);
      await pr!.hide();
      PaymentCardInfo cardInfo = PaymentCardInfo.fromJson(response);
      print(cardInfo.toString());
      if (cardInfo.status!.success!) {
        if (cardInfo.cardInfo != null && cardInfo.cardInfo!.length > 0) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      await pr!.hide();
      return false;
    }
  }
}
