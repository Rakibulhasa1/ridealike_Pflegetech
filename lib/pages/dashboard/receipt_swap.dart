import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../utils/app_events/app_events_utils.dart';
Future<Resp> fetchBookingData(_bookingID) async {
  var completer = Completer<Resp>();
  callAPI(
    getBookingByIDUrl,
    json.encode({"BookingID": _bookingID}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<Resp> fetchCarDetails(_carID) async {
  var completer = Completer<Resp>();
  callAPI(
    getCarUrl,
    json.encode({"CarID": _carID}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<Resp> fetchUsersDetails(_userIDs) async {
  var completer = Completer<Resp>();
  callAPI(
    getProfilesByUserIDsUrl,
    json.encode({"UserIDs": _userIDs}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
Future<Resp> getTripByID(String tripID) async {
  var getTripByIDCompleter = Completer<Resp>();
  callAPI(getTripByIDUrl, json.encode({"TripID": tripID})).then((resp) {
    getTripByIDCompleter.complete(resp);
  });

  return getTripByIDCompleter.future;
}

class ReceiptSwap extends StatefulWidget {
  @override
  State createState() => ReceiptSwapState();
}

class ReceiptSwapState extends State<ReceiptSwap> {
  //Map _receiptData = {};
  String? _bookingType;
  String user = '';
  final storage = new FlutterSecureStorage();
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  String userID = "";
  bool _dataLoading = true;
  String guestName = "";
  String guestFirstName = "";
  String hostName = "";
  String hostFirstName = "";
  String guestCarId = "";
  String hostCarId = "";
  String guestCarName = "";
  String hostCarName = "";
  String hostCarMileage = "";

  int hostCarMileageLimit=0;
  String pickupDate = "";
  String returnDate = "";
  String bookingDate = "";
  String cancellationDate = "";
  String tripSBN = "";
  String bookingStatus='';
  String tripCost = "";
  String locationName = "";
  String deliveryFee = "";
  String hostId = "";
  String guestId = "";
  var hostPayment;
  var guestPayment;

  String receivaleTitle = "";
  String payableTitle = "";
  double receivable = 0.0;
  double payable = 0.0;
  double income = 0.0;
  double insurance = 0.0;
  double fee = 0.0;
  double discountPer = 0.0;
  double discountAmount = 0.0;
  double discountProvided = 0.0;
  double total = 0.0;
  double cancelledTotal = 0.0;
  double latePickUpFee = 0.0;
  double cleaningFee = 0.0;
  double fuelChargeFee = 0.0;
  double extraMileageFee = 0.0;
  double tollChargeFee = 0.0;
  double damageFee = 0.0;
  double lateReturnFee = 0.0;

  double latePickUpCredit = 0.0;
  double cleaningFeeCredit = 0.0;
  double extraMileageCredit = 0.0;
  double fuelChargeCredit = 0.0;
  double tollCredit = 0.0;
  double damageFeeCredit = 0.0;
  double lateReturnCredit = 0.0;
  String? guestCarNamePayableTitle;
  String? hostCarNameReceivableTitle;
  String? costHeading;
 var cancellationFeeCredit;
 var cancellationFeeCreditValue;
 double refund =0;
  Trips? tripIDValues;
  Trips? otherTripIDValues;
  final oCcy = NumberFormat("#,##0.00", "en_US");
  var endedTripIdTimeFormat;
  var startedTripIdTimeFormat;
  //TODO

  void _printScreen() async {
    final pdf = pw.Document();

    double _textFont = 12.5;
    double _textMargin = 8;

    //custom font for pdf
    final fontData = await rootBundle.load("fonts/BalooDa2-Regular.ttf");
    final fontBalooDa2Regular = pw.Font.ttf(fontData);

    final PdfImage assetImage =  PdfImage.file( pdf.document, bytes: (await rootBundle.load('images/Logo.png'))
        .buffer
        .asUint8List(),);

pdf.addPage(pw.MultiPage(maxPages: 1,
    pageFormat: PdfPageFormat.a4,

build:(pw.Context context) => <pw.Widget>[
  pw.Container(
      child:
  pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Image(
          assetImage as pw.ImageProvider,
          height: 30,
          width: 30,),
        pw.SizedBox(height: 5,),
        pw.Text("RideAlike", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20,),),
        pw.SizedBox(height: 20,),
        pw.Text('TRIP ID: SBN$tripSBN', style: pw.TextStyle(fontSize: 15,),),
        pw.SizedBox(height: 20,),
      ])),
pw.Column(mainAxisSize: pw.MainAxisSize.max,
crossAxisAlignment: pw.CrossAxisAlignment.start,
    children:
    <pw.Widget>[
      pw.Text('SWAP DETAILS',
        style: pw.TextStyle(fontSize: 15,),),
      pw.SizedBox(height: _textMargin,),
      pw.Row(children: [
        pw.Text(
          // "Host",
          "Swapper",
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          hostName,
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
      ]),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Row(children: [
        pw.Text(
          // "Host Car",
          '${hostFirstName}\'s vehicle',
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          hostCarName,
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
      ]),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Row(children: [
        pw.Text(
          // "Guest",
          "Swapper",
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          guestName,
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
      ]),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Row(children: [
        pw.Text(
          // "Guest Car",
      '${guestFirstName}\'s vehicle',
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          guestCarName,
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
      ]),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Row(children: [
        pw.Text(
          "Booking Date",
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          bookingDate,
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
      ]),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Row(children: [
        pw.Text(
          "Pickup Date",
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          pickupDate,
          style: pw.TextStyle(
            fontSize: 15,
          ),
        ),
      ]),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Row(
        children: [
          pw.Text(
            "Return Date",
            style: pw.TextStyle(
              fontSize: 15,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            returnDate,
            style: pw.TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
      pw.SizedBox(
        height: _textMargin,
      ),
      ///started AT time///
      bookingStatus != 'Cancelled' && startedTripIdTimeFormat !=null?
      pw.Row(
        children: [
          pw.Text(
            'Start Trip Date',
            style: pw.TextStyle(
              fontSize: 16,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            startedTripIdTimeFormat.toString(),
            style: pw.TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      )
          : pw.Container(),
      bookingStatus != 'Cancelled' && startedTripIdTimeFormat!=null? pw.SizedBox(height: _textMargin) : pw.Container(),
      ///end trip date
      bookingStatus != 'Cancelled' && endedTripIdTimeFormat!=null ? pw.Row(
        children: [
          pw.Text(
            'End Trip Date',
            style: pw.TextStyle(
              fontSize: 16,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            endedTripIdTimeFormat.toString(),
            style: pw.TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      )
          : pw.Container(),
      bookingStatus != 'Cancelled' && endedTripIdTimeFormat!=null ?
      pw.SizedBox(height: _textMargin) : pw.Container(),
      bookingStatus=='Cancelled' && cancellationDate!=null?
      pw.Row(
        children: [
          pw.Text(
            "Cancelled Date",
            style: pw.TextStyle(
              fontSize: 15,
            ),
          ),
          pw.Spacer(),
          bookingStatus=='Cancelled' && cancellationDate!=null?
          pw.Text(
            cancellationDate,
            style: pw.TextStyle(
              fontSize: 15,
            ),
          ):pw.Text('0.00',style: pw.TextStyle(
            fontSize: 15,
          ),),
        ],
      ):pw.Container(),
      bookingStatus=='Cancelled' && cancellationDate!=null?
      pw.SizedBox(
        height: _textMargin,
      ):pw.Container(),
      pw.Row(
        children: [
          pw.Text(
            "Location",
            style: pw.TextStyle(
              fontSize: 15,
            ),
          ),
          pw.Spacer(),
          pw.Container(
            child: pw.Text(
              locationName,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: fontBalooDa2Regular,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(
        height: _textMargin,
      ),
      pw.Column(mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Text(
              'TRIP $costHeading',
              style: pw.TextStyle(
                fontSize: 15,
              ),
            ),
            pw.SizedBox(
              height: _textMargin,
            ),
          ]),
      pw.SizedBox(
        height: _textMargin,
      ),
                  pw.Row(
                    children: [
                      pw.Text(
                        guestCarNamePayableTitle!,
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        "\$${oCcy.format(payable).replaceAll("-", "")}",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: _textMargin,
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                    hostCarNameReceivableTitle!,
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        "\$${oCcy.format(receivable).replaceAll("-", "")}",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: _textMargin,
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        // income < 0.0 ? 'Trip cost' : 'Trip Income',
                        income <= 0.0 ? 'Trip Cost' : 'Trip Earnings',
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        "\$${oCcy.format(income).replaceAll("-", "")}",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: _textMargin,
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Insurance Fee',
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        "\$${oCcy.format(insurance).replaceAll("-", "")}",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: _textMargin,
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Service Fee',
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        "\$${oCcy.format(fee).replaceAll("-", "")}",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: _textMargin,),
                  ///pickup Fee//
                  bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?
                  pw.Row(
                    children: [
                      pw.Text(
                        "Pickup Fee",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(
                            fontSize: 14,

                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                  ///cleaning fee//
                  bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?
                  pw.Row(
                    children: [
                      pw.Text(
                        "Cleaning Fee",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(
                            fontSize: 14,
                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                  ///Extra mileage fee//
                  bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?
                  pw.Row(
                    children: [
                      pw.Text(
                        "Extra Mileage Charge",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(
                            fontSize: 14,
                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                  /// fuel charge//
                  bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?
                  pw.Row(
                    children: [
                      pw.Text(
                        "Fuel Charge",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(
                            fontSize: 14,
                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                  /// toll  fee//
                  bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?
                  pw.Row(
                    children: [

                      pw.Text(
                        "Toll Fee",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(
                            fontSize: 14,
                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?pw.SizedBox(height: _textMargin):pw.Container() ,
                  bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?
                  pw.Row(
                    children: [

                      pw.Text(
                        "Damage Fee",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(
                            fontSize: 14,
                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                  /// return fee//
                  bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?
                  pw.Row(
                    children: [

                      pw.Text(
                        "Return Fee",
                        style: pw.TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text('${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
                          style: pw.TextStyle(

                            fontSize: 14,

                          )
                      ),
                    ],
                  ):pw.Container(),
                  bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                   ])])
);
pdf.addPage(pw.MultiPage(build:(pw.Context context) => <pw.Widget>[
              ///pickup credit//
              bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?
              pw.Row(
                children: [
                  pw.Text(
                    "Pickup Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${latePickUpCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(
                        fontSize: 14,

                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
              ///cleaning credit//
              bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?
              pw.Row(
                children: [
                  pw.Text(
                    "Cleaning Fee Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${cleaningFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(
                        fontSize: 14,
                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
              ///Extra mileage credit//
              bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?
              pw.Row(
                children: [
                  pw.Text(
                    "Extra Mileage Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${extraMileageCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(
                        fontSize: 14,
                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
              /// fuel credit//
              bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?
              pw.Row(
                children: [
                  pw.Text(
                    "Fuel Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${fuelChargeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(
                        fontSize: 14,
                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
              /// toll  credit//
              bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?
              pw.Row(
                children: [
                  pw.Text(
                    "Toll Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${tollCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(
                        fontSize: 14,
                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?pw.SizedBox(height: _textMargin):pw.Container() ,
              ///damage credit//

              bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?
              pw.Row(
                children: [

                  pw.Text(
                    "Damage Fee Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${damageFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(
                        fontSize: 14,
                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
              /// return credit//
              bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?
              pw.Row(
                children: [

                  pw.Text(
                    "Return Credit",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text('${lateReturnCredit.toStringAsFixed(2).replaceAll("-", "")}',
                      style: pw.TextStyle(

                        fontSize: 14,

                      )
                  ),
                ],
              ):pw.Container(),
              bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
              ///mileage//
              pw.Row(
                children: [
                  hostCarMileage!=null && hostCarMileage=='Limited'?
                  pw.Text('$hostCarMileageLimit Total Kilometers Per Day',
                    style: pw.TextStyle(fontSize: 15,),)
                      : pw.Text('Unlimited Kilometers Per Day',
                    style: pw.TextStyle(
                    fontSize: 15,
                    ),
                   ),
                  pw.Spacer(),
                  pw.Text(
                    'Free',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(
                height: _textMargin,
              ),
             bookingStatus != 'Cancelled'?
              pw.Row(
                children: [
                  pw.Text(
                    total<0?'Total Trip Cost': 'Total Trip Earnings',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    "\$${oCcy.format(total).replaceAll("-", "")}",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ):pw.Row(
                children: [
                  pw.Text(
                    cancelledTotal<0?'Total Trip Cost': 'Total Trip Earnings',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    "\$${oCcy.format(cancelledTotal).replaceAll("-", "")}",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(
                height: _textMargin,
              ),
              bookingStatus=='Cancelled' &&  cancellationFeeCredit!=null && cancellationFeeCredit!=''?  pw.Row(
                children: [
                  pw.Text(cancellationFeeCredit,
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    "\$${oCcy.format(cancellationFeeCreditValue).replaceAll("-", "")}",
                    style: pw.TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ):pw.Container(),
              bookingStatus=='Cancelled'?pw.SizedBox(height: _textMargin,):pw.Container(),
      bookingStatus=='Cancelled' &&
           cancellationFeeCreditValue!=null && refund!=null && cancellationFeeCreditValue==refund?pw.Container():
              bookingStatus=='Cancelled' &&  refund!=null ?  pw.Row(
                children: [
                  pw.Text(
                    refund<0?'Trip Cost':'Trip Refund',
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    "\$${oCcy.format(refund).replaceAll("-", "")}",
                    style: pw.TextStyle(
                      fontSize: 14,),
                  ),
                ],
              ):pw.Container(),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'RideAlike',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '2901 Bayview Ave, Suite 91117,',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Toronto ON, Canada M2K 2Y6',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
              )

] ));
    // pdf.addPage(pw.Page(
    //     pageFormat: PdfPageFormat.a4,
    //     build: (pw.Context context) {
    //       return pw.Container(
    //         //margin: pw.EdgeInsets.all(10),
    //         child: pw.Column(
    //           crossAxisAlignment: pw.CrossAxisAlignment.start,
    //           children: [
    //             pw.Image(
    //               assetImage,
    //               height: 30,
    //               width: 30,
    //             ),
    //             pw.SizedBox(
    //               height: 5,
    //             ),
    //             pw.Text(
    //               "RideAlike",
    //               style: pw.TextStyle(
    //                 fontWeight: pw.FontWeight.bold,
    //                 fontSize: 20,
    //               ),
    //             ),
    //             pw.SizedBox(
    //               height: 20,
    //             ),
    //             pw.Text(
    //               'TRIP ID: SBN$tripSBN',
    //               style: pw.TextStyle(
    //                 fontSize: 15,
    //               ),
    //             ),
    //             pw.Divider(),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Text(
    //               'SWAP DETAILS',
    //               style: pw.TextStyle(
    //                 fontSize: 15,
    //               ),
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(children: [
    //               pw.Text(
    //                 "Host",
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //               pw.Spacer(),
    //               pw.Text(
    //                 hostName,
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ]),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(children: [
    //               pw.Text(
    //                 "Host Car",
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //               pw.Spacer(),
    //               pw.Text(
    //                 hostCarName,
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ]),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(children: [
    //               pw.Text(
    //                 "Guest",
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //               pw.Spacer(),
    //               pw.Text(
    //                 guestName,
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ]),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(children: [
    //               pw.Text(
    //                 "Guest Car",
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //               pw.Spacer(),
    //               pw.Text(
    //                 guestCarName,
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ]),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(children: [
    //               pw.Text(
    //                 "Booking date",
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //               pw.Spacer(),
    //               pw.Text(
    //                 bookingDate,
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ]),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(children: [
    //               pw.Text(
    //                 "Pickup date",
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //               pw.Spacer(),
    //               pw.Text(
    //                 pickupDate,
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ]),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Return date",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   returnDate,
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             ///started AT time///
    //             bookingStatus != 'Cancelled' && tripIDValues != null &&
    //                tripIDValues!.startedAt != null
    //                 ? pw.Row(
    //               children: [
    //                 pw.Text(
    //                   'Start Trip Date',
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   startedTripIdTimeFormat.toString(),
    //                   style: pw.TextStyle(
    //                     fontSize: 14,
    //                   ),
    //                 ),
    //               ],
    //             )
    //                 : pw.Container(),
    //             bookingStatus != 'Cancelled' && tripIDValues != null &&tripIDValues!.startedAt!= null &&
    //                tripIDValues!.startedAt != '' ? pw.SizedBox(height: _textMargin) : pw.Container(),
    //             ///end trip date
    //             bookingStatus != 'Cancelled' && tripIDValues != null &&
    //                tripIDValues!.endedAt != null &&tripIDValues!.endedAt != ''
    //                 ? pw.Row(
    //               children: [
    //                 pw.Text(
    //                   'End Trip Date',
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   endedTripIdTimeFormat.toString(),
    //                   style: pw.TextStyle(
    //                     fontSize: 14,
    //                   ),
    //                 ),
    //               ],
    //             )
    //                 : pw.Container(),
    //             bookingStatus != 'Cancelled' && tripIDValues != null &&
    //                tripIDValues!.endedAt != null &&tripIDValues!.endedAt != ''
    //                 ? pw.SizedBox(height: _textMargin) : pw.Container(),
    //             bookingStatus=='Cancelled' && cancellationDate!=null?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Cancelled date",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 bookingStatus=='Cancelled' && cancellationDate!=null?
    //                 pw.Text(
    //                   cancellationDate,
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ):pw.Text('0.00',style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus=='Cancelled' && cancellationDate!=null?
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ):pw.Container(),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Location",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Container(
    //                   constraints: pw.BoxConstraints(
    //                     maxWidth: SizeConfig.deviceWidth!* 0.8,
    //                   ),
    //                   child: pw.Text(
    //                     locationName,
    //                     textAlign: pw.TextAlign.right,
    //                     style: pw.TextStyle(
    //                       font: fontBalooDa2Regular,
    //                       fontSize: 15,
    //                     ),
    //                   ),
    //                 ),
    //
    //
    //               ],
    //             ),
    //             pw.Divider(),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Text(
    //               'TRIP COST',
    //               style: pw.TextStyle(
    //                 fontSize: 15,
    //               ),
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   guestCarNamePayableTitle,
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(payable).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //               hostCarNameReceivableTitle,
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(receivable).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   income < 0.0 ? 'Trip cost' : 'Trip Income',
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(income).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   'Insurance fee',
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(insurance).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   'Service fee',
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(fee).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(height: _textMargin,),
    //             ///pickup Fee//
    //             bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Pickup Fee",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             ///cleaning fee//
    //             bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Cleaning Fee",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             ///Extra mileage fee//
    //             bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?
    //             pw.Row(
    //
    //               children: [
    //
    //                 pw.Text(
    //                   "Extra Mileage Charge",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             /// fuel charge//
    //             bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Fuel Charge",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             /// toll  fee//
    //             bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Toll Fee",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?pw.SizedBox(height: _textMargin):pw.Container() ,
    //             bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Damage Fee",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             /// return fee//
    //             bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Return Fee",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //
    //                       fontSize: 14,
    //
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             ///pickup credit//
    //             bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Pickup Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${latePickUpCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             ///cleaning credit//
    //             bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Cleaning Fee Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${cleaningFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             ///Extra mileage credit//
    //             bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Extra Mileage Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${extraMileageCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             /// fuel credit//
    //             bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Fuel Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${fuelChargeCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             /// toll  credit//
    //             bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?
    //             pw.Row(
    //               children: [
    //                 pw.Text(
    //                   "Toll Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${tollCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?pw.SizedBox(height: _textMargin):pw.Container() ,
    //             ///damage credit//
    //
    //             bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Damage Fee Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${damageFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //                       fontSize: 14,
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             /// return credit//
    //             bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?
    //             pw.Row(
    //               children: [
    //
    //                 pw.Text(
    //                   "Return Credit",
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text('${lateReturnCredit.toStringAsFixed(2).replaceAll("-", "")}',
    //                     style: pw.TextStyle(
    //
    //                       fontSize: 14,
    //
    //                     )
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
    //             ///mileage//
    //             pw.Row(
    //               children: [
    //                 hostCarMileage!=null && hostCarMileage=='Limited'?
    //                 pw.Text('$hostCarMileageLimit Total Kilometers Per Day',
    //                   style: pw.TextStyle(fontSize: 15,),)
    //                     : pw.Text('Unlimited Kilometers Per Day',
    //                   style: pw.TextStyle(
    //                   fontSize: 15,
    //                   ),
    //                  ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   'Free',
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             pw.Row(
    //               children: [
    //                 pw.Text(   total<0?'Total Trip Cost':
    //                 'Total Trip Income',
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(total).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 15,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             pw.SizedBox(
    //               height: _textMargin,
    //             ),
    //             bookingStatus=='Cancelled' &&  cancellationFeeCredit!=null && cancellationFeeCredit!=''?  pw.Row(
    //               children: [
    //                 pw.Text(cancellationFeeCredit,
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(cancellationFeeCreditValue).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 14,
    //                   ),
    //                 ),
    //               ],
    //             ):pw.Container(),
    //             bookingStatus=='Cancelled'?pw.SizedBox(height: _textMargin,):pw.Container(),
    //             bookingStatus=='Cancelled' &&  refund!=null ?  pw.Row(
    //               children: [
    //                 pw.Text(
    //                   refund<0?'Trip Cost':'Trip Refund',
    //                   style: pw.TextStyle(
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 pw.Spacer(),
    //                 pw.Text(
    //                   "\$${oCcy.format(refund).replaceAll("-", "")}",
    //                   style: pw.TextStyle(
    //                     fontSize: 14,),
    //                 ),
    //               ],
    //             ):pw.Container(),
    //
    //             pw.Align(
    //               alignment: pw.Alignment.center,
    //               child: pw.Text(
    //                 'RideAlike',
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ),
    //             pw.Align(
    //               alignment: pw.Alignment.center,
    //               child: pw.Text(
    //                 '2901 Bayview Ave, Suite 91117,',
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             ),
    //             pw.Align(
    //               alignment: pw.Alignment.center,
    //               child: pw.Text(
    //                 'Toronto ON, Canada M2K 2Y6',
    //                 style: pw.TextStyle(
    //                   fontSize: 15,
    //                 ),
    //               ),
    //             )
    //           ],
    //         ),
    //       );
    //     }));

    if (Platform.isIOS) {
      await Printing.sharePdf(
          bytes: pdf.save() as Uint8List, filename: 'ridealike_receipt.pdf');

    } else {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    }
  }
  void _printSingleScreen() async {
    final pdf = pw.Document();

    double _textFont = 12.5;
    double _textMargin = 8;

    //custom font for pdf
    final fontData = await rootBundle.load("fonts/BalooDa2-Regular.ttf");
    final fontBalooDa2Regular = pw.Font.ttf(fontData);

    final PdfImage assetImage = PdfImage.file( pdf.document,
      // image: const AssetImage('images/Logo.png'),
      bytes: (await rootBundle.load('images/Logo.png'))
        .buffer
        .asUint8List(),);



    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            //margin: pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Image(
                  assetImage as pw.ImageProvider,
                  height: 30,
                  width: 30,
                ),
                pw.SizedBox(
                  height: 5,
                ),
                pw.Text(
                  "RideAlike",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                pw.SizedBox(
                  height: 20,
                ),
                pw.Text(
                  'TRIP ID: SBN$tripSBN',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Text(
                  'SWAP DETAILS',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    // "Host",
                    "Swapper",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    hostName,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ]),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    // "Host Car",
                    '${hostFirstName}\'s vehicle',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    hostCarName,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ]),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    // "Guest",
                    "Swapper",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    guestName,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ]),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    // "Guest Car",
                '${guestFirstName}\'s vehicle',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    guestCarName,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ]),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    "Booking Date",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    bookingDate,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ]),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    "Pickup Date",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    pickupDate,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ]),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      "Return Date",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      returnDate,
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                ///started AT time///
                bookingStatus != 'Cancelled' && startedTripIdTimeFormat != null ?
                pw.Row(
                  children: [
                    pw.Text(
                      'Start Trip Date',
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      startedTripIdTimeFormat.toString(),
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                    : pw.Container(),
                bookingStatus != 'Cancelled' && startedTripIdTimeFormat != null  ?
                pw.SizedBox(height: _textMargin) : pw.Container(),
                ///end trip date
                bookingStatus != 'Cancelled' && endedTripIdTimeFormat!= null
                    ? pw.Row(
                  children: [
                    pw.Text(
                      'End Trip Date',
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      endedTripIdTimeFormat.toString(),
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                    : pw.Container(),
                bookingStatus != 'Cancelled' && endedTripIdTimeFormat!= null ?
                pw.SizedBox(height: _textMargin) : pw.Container(),
                bookingStatus=='Cancelled' && cancellationDate!=null?
                pw.Row(
                  children: [
                    pw.Text(
                      "Cancelled Date",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    bookingStatus=='Cancelled' && cancellationDate!=null?
                    pw.Text(
                      cancellationDate,
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ):pw.Text('0.00',style: pw.TextStyle(
                      fontSize: 15,
                    ),),
                  ],
                ):pw.Container(),
                bookingStatus=='Cancelled' && cancellationDate!=null?
                pw.SizedBox(
                  height: _textMargin,
                ):pw.Container(),
                pw.Row(
                  children: [
                    pw.Text(
                      "Location",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Container(
                      constraints: pw.BoxConstraints(
                        maxWidth: SizeConfig.deviceWidth!* 0.8,
                      ),
                      child: pw.Text(
                        locationName,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          font: fontBalooDa2Regular,
                          fontSize: 15,
                        ),
                      ),
                    ),


                  ],
                ),
                pw.Divider(),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Text(
                  'TRIP $costHeading',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      guestCarNamePayableTitle!,
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(payable).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(
                  children: [
                    pw.Text(
                  hostCarNameReceivableTitle!,
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(receivable).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      income <= 0.0? 'Trip Cost' : 'Trip Earnings',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(income).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'Insurance Fee',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(insurance).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'Service Fee',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(fee).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: _textMargin,),
                ///pickup Fee//
                bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Pickup Fee",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,

                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                ///cleaning fee//
                bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Cleaning Fee",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                ///Extra mileage fee//
                bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?
                pw.Row(

                  children: [

                    pw.Text(
                      "Extra Mileage Charge",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                /// fuel charge//
                bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?
                pw.Row(
                  children: [

                    pw.Text(
                      "Fuel Charge",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                /// toll  fee//
                bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?
                pw.Row(
                  children: [

                    pw.Text(
                      "Toll Fee",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?pw.SizedBox(height: _textMargin):pw.Container() ,
                bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?
                pw.Row(
                  children: [

                    pw.Text(
                      "Damage Fee",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                /// return fee//
                bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?
                pw.Row(
                  children: [

                    pw.Text(
                      "Return Fee",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(

                          fontSize: 14,

                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                ///pickup credit//
                bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Pickup Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${latePickUpCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,

                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                ///cleaning credit//
                bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Cleaning Fee Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${cleaningFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                ///Extra mileage credit//
                bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Extra Mileage Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${extraMileageCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                /// fuel credit//
                bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Fuel Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${fuelChargeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                /// toll  credit//
                bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?
                pw.Row(
                  children: [
                    pw.Text(
                      "Toll Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${tollCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?pw.SizedBox(height: _textMargin):pw.Container() ,
                ///damage credit//

                bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?
                pw.Row(
                  children: [

                    pw.Text(
                      "Damage Fee Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${damageFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(
                          fontSize: 14,
                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                /// return credit//
                bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?
                pw.Row(
                  children: [

                    pw.Text(
                      "Return Credit",
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('${lateReturnCredit.toStringAsFixed(2).replaceAll("-", "")}',
                        style: pw.TextStyle(

                          fontSize: 14,

                        )
                    ),
                  ],
                ):pw.Container(),
                bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?pw.SizedBox(height: _textMargin):pw.Container(),
                ///mileage//
                pw.Row(
                  children: [
                    hostCarMileage!=null && hostCarMileage=='Limited'?
                    pw.Text('$hostCarMileageLimit Total Kilometers Per Day',
                      style: pw.TextStyle(fontSize: 15,),)
                        : pw.Text('Unlimited Kilometers Per Day',
                      style: pw.TextStyle(
                      fontSize: 15,
                      ),
                     ),
                    pw.Spacer(),
                    pw.Text(
                      'Free',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                bookingStatus != 'Cancelled'?
                pw.Row(
                  children: [
                    pw.Text(
                      total<0?'Total Trip Cost': 'Total Trip Earnings',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(total).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ) :pw.Row(
                  children: [
                    pw.Text(
                      cancelledTotal<0?'Total Trip Cost': 'Total Trip Earnings',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(cancelledTotal).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                bookingStatus=='Cancelled' &&  cancellationFeeCredit!=null && cancellationFeeCredit!=''?  pw.Row(
                  children: [
                    pw.Text(cancellationFeeCredit,
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(cancellationFeeCreditValue).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ):pw.Container(),
                bookingStatus=='Cancelled'?pw.SizedBox(height: _textMargin,):pw.Container(),
                bookingStatus=='Cancelled' &&
                    cancellationFeeCreditValue!=null && refund!=null && cancellationFeeCreditValue==refund?pw.Container():
                bookingStatus=='Cancelled' &&  refund!=null ?  pw.Row(
                  children: [
                    pw.Text(
                      refund<0?'Trip Cost':'Trip Refund',
                      style: pw.TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      "\$${oCcy.format(refund).replaceAll("-", "")}",
                      style: pw.TextStyle(
                        fontSize: 14,),
                    ),
                  ],
                ):pw.Container(),

                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'RideAlike',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '2901 Bayview Ave, Suite 91117,',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Toronto ON, Canada M2K 2Y6',
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          );
        }));

    if (Platform.isIOS) {
      await Printing.sharePdf(
          bytes: pdf.save() as Uint8List, filename: 'ridealike_receipt.pdf');

    } else {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    }
  }

  @override
  void initState() {
    super.initState();

    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Swap Receipt"});

    Future.delayed(Duration.zero, () async {
      userID = (await storage.read(key: 'user_id'))!;

      // print("userId " + userID);

      final Trips trips = ModalRoute.of(context)!.settings.arguments as Trips;
      String bookingID= trips.bookingID!;
      print("bookingId $bookingID");
      print("+++++++++++++++++++++++++++++++");
      // print(userID);
      print("+++++++++++++++++++++++++++++++");
      var bookingData = await fetchBookingData(bookingID);
      print("+++++++++++++++++++++++++++++++");
      print(json.decode(bookingData.body!)['Booking']["SwapHostA"]);
      print("+++++++++++++++++++++++++++++++");
      print(json.decode(bookingData.body!)['Booking']["SwapHostB"]);
      print("+++++++++++++++++++++++++++++++");
      var tripID = json.decode(bookingData.body!)['Booking']['TripID'];

      var resTripID = await getTripByID(tripID);

      if (resTripID != null) {
        tripIDValues =Trips.fromJson(json.decode(resTripID.body!)['Trip']);
        print('tripIDValues$tripIDValues');
      }
      var otherTripID=tripIDValues!.swapData!.otherTripID;
      if(otherTripID!=null){
        var resOtherTripID = await getTripByID(otherTripID);
        otherTripIDValues =Trips.fromJson(json.decode(resOtherTripID.body!)['Trip']);
        print('tripIDValues$otherTripIDValues');
      }

      // var  endedAtTripTime =tripIDValues!.endedAt;
      // var startedAtTripTime =tripIDValues!.startedAt;
      var swapHost;
      var swapGuest;
      if (json.decode(bookingData.body!)['Booking']["SwapHostA"]["UserID"] == json.decode(bookingData.body!)['Booking']["Params"]["UserID"]) {
        swapHost = json.decode(bookingData.body!)['Booking']["SwapHostB"];
        swapGuest = json.decode(bookingData.body!)['Booking']["SwapHostA"];

      } else {
        swapHost = json.decode(bookingData.body!)['Booking']["SwapHostA"];
        swapGuest = json.decode(bookingData.body!)['Booking']["SwapHostB"];

      }

      hostId = swapHost["UserID"];
      hostCarId = swapHost["MyCarID"];
      guestId = swapGuest["UserID"];
      guestCarId = swapHost["TheirCarID"];
      guestPayment = swapGuest;
      hostPayment = swapHost;

      print("+++++++++++++++++++++++++++++++");
      print('HostId$hostId');
      print("+++++++++++++++++++++++++++++++");
      print('GuestID$guestId');
      print("+++++++++++++++++++++++++++++++");
      print('hostCarId$hostCarId');
      var data;
      var hostCarData = await fetchCarDetails(hostCarId);

      var guestCarData = await fetchCarDetails(guestCarId);

      var userData = await fetchUsersDetails([ guestId,hostId]);

      setState(() {
        tripSBN = json.decode(bookingData.body!)['Booking']['SBN'];
        locationName = json.decode(bookingData.body!)['Booking']['Params']['PickupReturnLocation']['Address'];
        pickupDate = DateFormat('EE, MMM dd, hh:00 a').format(DateTime.parse(json.decode(bookingData.body!)['Booking']['Params']['StartDateTime']).toLocal());
        returnDate = DateFormat('EE, MMM dd, hh:00 a').format(DateTime.parse(json.decode(bookingData.body!)['Booking']['Params']['EndDateTime']).toLocal());
        bookingDate = DateFormat('EE, MMM dd, hh:mm a').format(DateTime.parse(json.decode(bookingData.body!)['Booking']['BookingDate']).toLocal());
        json.decode(bookingData.body!)['Booking']['CancellationFee']!=null?
        cancellationDate =DateFormat('EE, MMM dd, hh:mm a').format(DateTime.parse(json.decode(bookingData.body!)['Booking']['CancellationFee']['CancelledDate']).toLocal()):0.00;


        hostCarName = trips.car==null?"Deleted Car": json.decode(hostCarData.body!)['Car']['About']['Make'] + ' ' + json.decode(hostCarData.body!)['Car']['About']['Model'];
        hostCarMileage=trips.car==null?"Undefined": json.decode(hostCarData.body!)['Car']['Preference']['DailyMileageAllowance'];
        hostCarMileageLimit= trips.car==null?0: json.decode(hostCarData.body!)['Car']['Preference']['Limit'];
        bookingStatus=json.decode(bookingData.body!)['Booking']["BookingStatus"];

        guestCarName =json.decode(guestCarData.body!)['Car']['About']['Make'] + ' ' + json.decode(guestCarData.body!)['Car']['About']['Model'];


        guestName =json.decode(userData.body!)['Profiles'][0]['UserID']== guestId?
        (json.decode(userData.body!)['Profiles'][0]['FirstName'] + ' ' +
            json.decode(userData.body!)['Profiles'][0]['LastName'] ) :
        json.decode(userData.body!)['Profiles'][1]['UserID']== guestId?
        (json.decode(userData.body!)['Profiles'][1]['FirstName'] + ' ' +
            json.decode(userData.body!)['Profiles'][1]['LastName'] ):'';

        hostName = trips.car==null?"Deleted Host Profile": json.decode(userData.body!)['Profiles'][0]['UserID']== hostId?
        (json.decode(userData.body!)['Profiles'][0]['FirstName'] + ' ' +
            json.decode(userData.body!)['Profiles'][0]['LastName'] ) :
        json.decode(userData.body!)['Profiles'][1]['UserID']== hostId?
           (json.decode(userData.body!)['Profiles'][1]['FirstName'] + ' ' +
            json.decode(userData.body!)['Profiles'][1]['LastName'] ):'';
        ///guest first name//
        guestFirstName =json.decode(userData.body!)['Profiles'][0]['UserID']== guestId?
        (json.decode(userData.body!)['Profiles'][0]['FirstName']) :
        json.decode(userData.body!)['Profiles'][1]['UserID']== guestId?
        (json.decode(userData.body!)['Profiles'][1]['FirstName']):'';
///host First Name///
        hostFirstName =json.decode(userData.body!)['Profiles'][0]['UserID']== hostId?
        (json.decode(userData.body!)['Profiles'][0]['FirstName']) :
        json.decode(userData.body!)['Profiles'][1]['UserID']== hostId?
           (json.decode(userData.body!)['Profiles'][1]['FirstName']):'';


        if (json.decode(bookingData.body!)['Booking']["SwapHostA"]["UserID"] == userID) {
          if(json.decode(bookingData.body!)['Booking']['CancellationFee']!=null)
          {
            refund= double.parse(json.decode(bookingData.body!)['Booking']['CancellationFee']['HostARefund'].toString());

          }

        } else {
          if(json.decode(bookingData.body!)['Booking']['CancellationFee']!=null){
          refund= double.parse(json.decode(bookingData.body!)['Booking']['CancellationFee']['HostBRefund'].toString());
          }

        }

        if(userID == guestPayment["UserID"]) {
          income = double.parse(guestPayment["income"].toString());
          fee = double.parse(guestPayment["RidealikeFee"].toString());
          // total = double.parse(guestPayment["Total"].toString());
          cancelledTotal = double.parse(guestPayment["Total"].toString());
          total = double.parse(tripIDValues!.guestTotal.toString());
          insurance = double.parse(guestPayment["insuranceFee"].toString());
          payableTitle = guestPayment["PayableRateString"];
          receivaleTitle = guestPayment["RecievableRateString"];
          guestCarNamePayableTitle= '$guestCarName ($receivaleTitle )';
          hostCarNameReceivableTitle = '$hostCarName ($payableTitle )';
          receivable = double.parse(guestPayment["Payable"].toString());
          payable = double.parse(guestPayment["Recievable"].toString());


        } else{
          income = double.parse(hostPayment["income"].toString());
          fee = double.parse(hostPayment["RidealikeFee"].toString());
          cancelledTotal = double.parse(hostPayment["Total"].toString());
          total = double.parse(tripIDValues!.hostTotal.toString());
          insurance = double.parse(hostPayment["insuranceFee"].toString());


          payableTitle = hostPayment["PayableRateString"];
          receivaleTitle = hostPayment["RecievableRateString"];
          guestCarNamePayableTitle=  '$hostCarName ( $receivaleTitle )';
          hostCarNameReceivableTitle = '$guestCarName ( $payableTitle )';
          receivable = double.parse(hostPayment["Payable"].toString());
          payable = double.parse(hostPayment["Recievable"].toString());

        }

        if (json.decode(bookingData.body!)['Booking']["BookingStatus"].toString() == "Cancelled") {
          var data =json.decode(bookingData.body!);
          if(data['Booking']['CancellationFee']!=null && data['Booking']['CancellationFee']['CancellationProfit'] != null  &&
              (data['Booking']['CancellationFee']['CancellationProfit']['WhoPaidUserID'] == userID  ||
                  data['Booking']['CancellationFee']['CancellationProfit']['WhoPaidUserID'] =='')  ){
              cancellationFeeCredit='Cancellation Fee';
            cancellationFeeCreditValue=data['Booking']['CancellationFee']['CancellationFee'];
          }else{
            cancellationFeeCredit='Cancellation Credit';
            cancellationFeeCreditValue=data['Booking']['CancellationFee']['CancellationProfit']['Ammount'];

          }
        }

        _dataLoading = false;
   if(userID == guestPayment["UserID"]){
     if (tripIDValues != null &&tripIDValues!.endedAt!= null ) {
       endedTripIdTimeFormat = DateFormat('EE MMM dd, hh:mm a').format(tripIDValues!.endedAt!.toLocal());

     }
     if (tripIDValues != null &&tripIDValues!.startedAt != null ) {
       startedTripIdTimeFormat = DateFormat('EE MMM dd, hh:mm a').format(tripIDValues!.startedAt!.toLocal());

     }
   }else{
     if (otherTripIDValues != null && otherTripIDValues!.endedAt!= null ) {
       endedTripIdTimeFormat = DateFormat('EE MMM dd, hh:mm a').format(otherTripIDValues!.endedAt!.toLocal());

     }
     if (otherTripIDValues != null && otherTripIDValues!.startedAt != null ) {
       startedTripIdTimeFormat = DateFormat('EE MMM dd, hh:mm a').format(otherTripIDValues!.startedAt!.toLocal());

     }
   }


        if(userID == guestPayment["UserID"]){
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.latePickup!=null ){
            latePickUpFee=tripIDValues!.otherFees!.latePickup!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.hostProfit!=null &&
              otherTripIDValues!.otherFees!.hostProfit!.latePickup!=null ){
            latePickUpCredit= otherTripIDValues!.otherFees!.hostProfit!.latePickup!;
          }

          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.lateReturn!=null ){
            lateReturnFee=tripIDValues!.otherFees!.lateReturn!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.hostProfit!=null &&
              otherTripIDValues!.otherFees!.hostProfit!.lateReturn!=null ){
            lateReturnCredit=otherTripIDValues!.otherFees!.hostProfit!.lateReturn!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.cleaning!=null ){
            cleaningFee=tripIDValues!.otherFees!.cleaning!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.cleaning!=null ){
            cleaningFeeCredit=otherTripIDValues!.otherFees!.cleaning!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.extraMileage!=null ){
            extraMileageFee=tripIDValues!.otherFees!.extraMileage!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.extraMileage!=null ){
            extraMileageCredit=otherTripIDValues!.otherFees!.extraMileage!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.fuelCharge!=null ){
            fuelChargeFee=tripIDValues!.otherFees!.fuelCharge!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.fuelCharge!=null ){
            fuelChargeCredit=otherTripIDValues!.otherFees!.fuelCharge!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.toll!=null ){
            tollChargeFee=tripIDValues!.otherFees!.toll!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.toll!=null ){
            tollCredit=otherTripIDValues!.otherFees!.toll!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.damage!=null ){
            damageFee=tripIDValues!.otherFees!.damage!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.damage!=null ){
            damageFeeCredit=otherTripIDValues!.otherFees!.damage!;
          }
        }else{
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.latePickup!=null ){
            latePickUpFee= otherTripIDValues!.otherFees!.latePickup!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.hostProfit!=null &&
             tripIDValues!.otherFees!.hostProfit!.latePickup!=null ){
            latePickUpCredit=tripIDValues!.otherFees!.hostProfit!.latePickup!;
          }

          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.lateReturn!=null ){
            lateReturnFee=otherTripIDValues!.otherFees!.lateReturn!;
          }

          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.hostProfit!=null &&
             tripIDValues!.otherFees!.hostProfit!.lateReturn!=null ){
            lateReturnCredit=tripIDValues!.otherFees!.hostProfit!.lateReturn!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.cleaning!=null ){
            cleaningFee=otherTripIDValues!.otherFees!.cleaning!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.cleaning!=null ){
            cleaningFeeCredit=tripIDValues!.otherFees!.cleaning!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.extraMileage!=null ){
            extraMileageFee=otherTripIDValues!.otherFees!.extraMileage!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.extraMileage!=null ){
            extraMileageCredit=tripIDValues!.otherFees!.extraMileage!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.fuelCharge!=null ){
            fuelChargeFee=otherTripIDValues!.otherFees!.fuelCharge!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.fuelCharge!=null ){
            fuelChargeCredit=tripIDValues!.otherFees!.fuelCharge!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.toll!=null ){
            tollChargeFee=otherTripIDValues!.otherFees!.toll!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.toll!=null ){
            tollCredit=tripIDValues!.otherFees!.toll!;
          }
          if(otherTripIDValues!=null && otherTripIDValues!.otherFees!=null && otherTripIDValues!.otherFees!.damage!=null ){
            damageFee=otherTripIDValues!.otherFees!.damage!;
          }
          if(tripIDValues!=null &&tripIDValues!.otherFees!=null &&tripIDValues!.otherFees!.damage!=null ){
            damageFeeCredit=tripIDValues!.otherFees!.damage!;
          }
        }

       if(bookingStatus=='Cancelled'){
         if(refund<0){
           costHeading='COST';
         }else{
           costHeading='REFUND';
         }
       }else{
         if(total<0){
             costHeading='COST';
         }else{
              costHeading='EARNINGS';
            }
       }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
        actions: [
          GestureDetector(
            onTap: () {
              if(
              (latePickUpCredit!=null && latePickUpCredit!=0)
                  || (lateReturnCredit!=null && lateReturnCredit!=0)
                 || (tollCredit!=null && tollCredit!=0)
                 || (damageFeeCredit!=null && damageFeeCredit!=0)
                 || (extraMileageCredit!=null && extraMileageCredit!=0)
                 || (cleaningFeeCredit!=null && cleaningFeeCredit!=0)
                 || (fuelChargeCredit!=null && fuelChargeCredit!=0)){
                _printScreen();
              }else{
                _printSingleScreen();
              }

            },
            child: Center(
              child: Container(
                margin: EdgeInsets.only(right: 16),
                child: Text(
                  'Download',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xffFF8F68),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: !_dataLoading
          ? RepaintBoundary(
              child: SingleChildScrollView(
                key: _printKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Receipt',
                            style: TextStyle(
                                color: Color(0xff371D32),
                                fontSize: 36,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      //trip id//
                      Text(
                        'TRIP ID: SBN$tripSBN',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xff371D32).withOpacity(0.5),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      SizedBox(height: 20),
                      Text(
                        'SWAP DETAILS',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xff371D32).withOpacity(0.5),
                        ),
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      //host//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Swapper',
                            // 'Host',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            hostName,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      //host ar//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // 'Host Car',
                            '${hostFirstName}\'s vehicle',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            hostCarName,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      ///guest//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Swapper',
                            // 'Guest',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            guestName,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // 'Guest Car',
                      '${guestFirstName}\'s vehicle',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            guestCarName,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      ///booking dates//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking Date',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            bookingDate,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pickup Date',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            pickupDate,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Return Date',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            returnDate,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      bookingStatus!= 'Cancelled' &&  startedTripIdTimeFormat!=null ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Start Trip Date',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.5,
                            textAlign: TextAlign.right,
                            text: startedTripIdTimeFormat.toString(),
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            textColor: Color(0xff353B50),
                          ),
                        ],
                      )
                          :

                      Container(),
                      bookingStatus!= 'Cancelled' && startedTripIdTimeFormat!=null ? Divider(color: Color(0xFFE7EAEB)) : Container(),
                      ///ended Date//
                      bookingStatus != 'Cancelled' && endedTripIdTimeFormat != null
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'End Trip Date',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.5,
                            textAlign: TextAlign.right,
                            text: endedTripIdTimeFormat.toString(),
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            textColor: Color(0xff353B50),
                          ),
                        ],
                      )
                          : Container(),
                      bookingStatus != 'Cancelled' && endedTripIdTimeFormat != null ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),
                      //cancelled date//
                      bookingStatus=='Cancelled'&& cancellationDate!=null &&cancellationDate!=''?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cancelled Date',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          bookingStatus=='Cancelled' && cancellationDate!=null?
                          Text(cancellationDate,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ):
                          Text('0.00',style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Color(0xff353B50),
                          ),),
                        ],
                      ):Container(),
                      bookingStatus=='Cancelled' && cancellationDate!=null?   Divider(color: Color(0xFFE7EAEB)):Container(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            locationName,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Color(0xff371D32),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      SizedBox(height: 20),
                      Text(
                        'TRIP $costHeading',
                        // 'TRIP COST',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xff371D32).withOpacity(0.5),
                        ),
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              // '$guestCarName (' + payableTitle + ')',
                              guestCarNamePayableTitle!,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xff371D32),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "\$${oCcy.format(payable).replaceAll("-", "")}",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              hostCarNameReceivableTitle!,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xff371D32),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "\$${oCcy.format(receivable).replaceAll("-", "")}",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // income < 0.0 ? 'Trip cost' : 'Trip Income',
                            income <= 0.0 ? 'Trip cost' : 'Trip Earnings',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(income).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Insurance fee',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(insurance).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      ///service fee//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service fee',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(fee).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      ///pickup Fee//
                      bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Pickup Fee',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && latePickUpFee!=null && latePickUpFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      ///cleaning fee//
                      bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Cleaning Fee',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && cleaningFee!=null && cleaningFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      ///Extra mileage fee//
                      bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Extra Mileage Charge',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && extraMileageFee!=null && extraMileageFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// fuel charge//
                      bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Fuel Charge',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && fuelChargeFee!=null && fuelChargeFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// toll  fee//
                      bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Toll Fee',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && tollChargeFee!=null && tollChargeFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      ///damage fee//
                      bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Damage Fee',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && damageFee!=null && damageFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// return fee//
                      bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Return Fee',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && lateReturnFee!=null && lateReturnFee!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// pickup Credit //
                      bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:'Pickup Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${latePickUpCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && latePickUpCredit!=null && latePickUpCredit!=0?Divider(color: Color(0xFFE7EAEB)):
                      Container(),
                      ///cleaning credit//
                      bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Cleaning Fee Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${cleaningFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && cleaningFeeCredit!=null && cleaningFeeCredit!=0?
                      Divider(color: Color(0xFFE7EAEB)):Container(),
                      ///Extra mileage credit//
                      bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Extra Mileage Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${extraMileageCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && extraMileageCredit!=null && extraMileageCredit!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// fuel credit//
                      bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Fuel Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${fuelChargeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && fuelChargeCredit!=null && fuelChargeCredit!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// toll  credit//
                      bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Toll Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${tollCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && tollCredit!=null && tollCredit!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      ///damage credit//
                      bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Damage Fee Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${damageFeeCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' && damageFeeCredit!=null && damageFeeCredit!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      /// return credit//
                      bookingStatus != 'Cancelled' && lateReturnCredit!=null && lateReturnCredit!=0?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.7,
                            text:
                            'Return Credit',
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            textColor: Color(0xff371D32),
                          ),
                          Text('${lateReturnCredit.toStringAsFixed(2).replaceAll("-", "")}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              )
                          ),
                        ],
                      ):Container(),
                      bookingStatus != 'Cancelled' &&
                          lateReturnCredit!=null && lateReturnCredit!=0?Divider(color: Color(0xFFE7EAEB)):Container(),
                      ///mileage//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                       hostCarMileage!=null && hostCarMileage=='Limited'?
                          Text(
                            '${hostCarMileageLimit} Total Kilometers Per Day',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ): Text(
                         'Unlimited Kilometers Per Day',
                         style: TextStyle(
                           fontFamily: 'Urbanist',
                           fontSize: 16,
                           color: Color(0xff371D32),
                         ),
                       ),
                          Text('Free',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color:Color(0xffFF8F68),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      ///trip total//
                      bookingStatus != 'Cancelled'?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            total<0?'Total Trip Cost':
                            'Total Trip Earnings',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(total).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ):
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cancelledTotal<0?'Total Trip Cost':
                            'Total Trip Earnings',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(cancelledTotal).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      //cancellation credit /cancellation fee//
                      bookingStatus=='Cancelled' &&  cancellationFeeCredit!=null &&
                          cancellationFeeCredit!=''?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                       Text(cancellationFeeCredit,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(cancellationFeeCreditValue).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ):Container(),
                      bookingStatus=='Cancelled'?Divider(color: Color(0xFFE7EAEB)):Container(),
                      bookingStatus=='Cancelled' &&
                          cancellationFeeCreditValue!=null && refund!=null && cancellationFeeCreditValue==refund?Container():
                      bookingStatus=='Cancelled' &&  refund!=null?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(refund<0?'Trip Cost':'Trip Refund',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            "\$${oCcy.format(refund).replaceAll("-", "")}",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ):Container(),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'RideAlike',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff371D32),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '2901 Bayview Ave, Suite 91117,',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff371D32),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Toronto ON, Canada M2K 2Y6',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff371D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(strokeWidth: 2.5)
                ],
              ),
            ),
    );
  }
}
