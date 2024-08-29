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
import 'package:ridealike/pages/dashboard/response_service/receipt_response_service.dart';
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

class LatestReceiptPage extends StatefulWidget {
  @override
  State createState() => ReceiptState();
}

class ReceiptState extends State<LatestReceiptPage> {
  // Map _receiptData = {};
  Map _receiptCarData = {};
  RentalBookingReceiptResponse? _receiptData;
  String? _bookingType;
  String user = '';
  String? guestUser;

  // var tripIDValues;
  Trips? tripIDValues;
  var endedTimeFormat;
  var startedTripIdTimeFormat;
  final storage = new FlutterSecureStorage();
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  var entalBookingReceiptResponse;
  String pickupDate = "";
  String previousPickupDate = "";
  String previousReturnDate = "";
  String returnDate = "";
  String cancellationDate = "";
  String tripSBN = "";
  String tripID = "";
  String tripIdRBN = "";
  String locationName = "";
  double price = 0.0;
  double discount = 0.0;
  double fee = 0.0;
  double total = 0.0;
  double? previousTotal;
  double? changeAmount;
  double latePickUpFee = 0.0;
  double lateReturnFee = 0.0;
  double cleaningFee = 0.0;
  double extraMileageFee = 0.0;
  double fuelChargeFee = 0.0;
  double tollChargeFee = 0.0;
  double damageFee = 0.0;
  double cancellationFee = 0.0;
  double cancellationFeeTotal = 0.0;
  double refund = 0.0;
  double deliveryFee = 0.0;
  String rate = '';
  String? duration;
  String? previousRate;
  String? previousDuration;
  double? discountPercentage;
  double? insuranceFee;
  double? ridealikeCouponFee;
  bool? couponAvailed;
  double? hostRidealikeFee;
  String bookingStatus = '';
  String deliveryFeeString = '';
  String? bookingDates;
  String? whoCancelled;
  var insurance;
  int? dayDifference;

  String? cancelledBookingDates;

  String? whoGained;

  String? whoPaid;
  int? receiptIndex;
  int? noOfChangeRequest;

  void _printScreen() async {
    final pdf = pw.Document();

    double _textFont = 12.5;
    double _textMargin = 8;

    //custom font for pdf
    final fontData = await rootBundle.load("fonts/BalooDa2-Regular.ttf");
    final fontBalooDa2Regular = pw.Font.ttf(fontData);

    final PdfImage assetImage = await PdfImage.file(
      pdf.document,
      bytes: (await rootBundle.load('images/Logo.png'))
          .buffer
          .asUint8List(),
    );


    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        maxPages: 1,
        build: (pw.Context context) => <pw.Widget>[
              pw.Container(
                //margin: pw.EdgeInsets.all(10),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                      'TRIP ID: ${'RBN$tripIdRBN'} ',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Divider(),
                    pw.SizedBox(
                      height: _textMargin,
                    ),
                    pw.Text(
                      'TRIP DETAILS',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.SizedBox(
                      height: _textMargin,
                    ),
                    pw.Row(children: [
                      pw.Text(
                        _bookingType!,
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        _receiptCarData['CarName'],
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
                        "Host",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        _receiptCarData['Host'],
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
                        "Guest",
                        style: pw.TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      pw.Spacer(),
                      pw.Text(
                        _receiptCarData['Guest'],
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
                          "Booking Date",
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          bookingDates!,
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
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

                    ///start trip time
                    bookingStatus != 'Cancelled' &&
                            tripIDValues != null &&
                            tripIDValues!.startedAt != null
                        ? pw.Row(
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
                    bookingStatus != 'Cancelled' &&
                            tripIDValues != null &&
                            tripIDValues!.startedAt != null
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    ///end trip date
                    bookingStatus != 'Cancelled' &&
                            tripIDValues != null &&
                            tripIDValues!.endedAt != null
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
                                endedTimeFormat.toString(),
                                style: pw.TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            tripIDValues != null &&
                            tripIDValues!.endedAt != null
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    bookingStatus == 'Cancelled' &&
                            _receiptData!.booking!.cancellationFee != null
                        ? pw.Row(
                            children: [
                              pw.Text(
                                "Cancelled Date",
                                style: pw.TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              pw.Spacer(),
                              pw.Text(
                                cancelledBookingDates!,
                                style: pw.TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus == 'Cancelled' &&
                            _receiptData!.booking!.cancellationFee != null
                        ? pw.SizedBox(
                            height: _textMargin,
                          )
                        : pw.Container(),
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
                      'TRIP COST',
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
                          "Trip Rate",
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          rate,
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
                          'Trip Cost',
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        pw.Spacer(),
                        pw.Text(
                          bookingStatus == 'Cancelled' && user == 'Host'
                              ? '\$' '0.00'
                              : '\$' +
                                  (price
                                      .toStringAsFixed(2)
                                      .replaceAll("-", "")),
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: _textMargin,
                    ),
                    bookingStatus == 'Cancelled' && user == 'Host'
                        ? pw.Container()
                        : deliveryFee != null && deliveryFee != 0
                            ? pw.Column(children: [
                                pw.Row(
                                  children: [
                                    deliveryFeeString != null &&
                                            deliveryFeeString != ''
                                        ? pw.Text(
                                            'Delivery Fee ($deliveryFeeString)',
                                            style: pw.TextStyle(
                                              fontSize: 15,
                                            ),
                                          )
                                        : pw.Text(
                                            'Delivery Fee',
                                            style: pw.TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                    pw.Spacer(),
                                    pw.Text(
                                      '\$' +
                                          deliveryFee
                                              .toStringAsFixed(2)
                                              .replaceAll("-", ""),
                                      style: pw.TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: _textMargin)
                              ])
                            : pw.Container(),
                    discountPercentage != null && discountPercentage != 0
                        ? pw.Column(children: [
                            pw.Row(
                              children: [
                                pw.Text(
                                  user == 'Guest'
                                      ? 'Guest Discount: ${discountPercentage!.toStringAsFixed(0)}% Off'
                                      : 'Host Discount: ${discountPercentage!.toStringAsFixed(0)}% Off',
                                  style: pw.TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                pw.Spacer(),
                                pw.Text(
                                  '\$${discount.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: _textMargin)
                          ])
                        : pw.Container(),
                    user == 'Guest'
                        ? pw.Row(
                            children: [
                              pw.Text(
                                'Insurance Fee',
                                style: pw.TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              pw.Spacer(),
                              pw.Text(
                                bookingStatus == 'Cancelled' && user == 'Host'
                                    ? '\$' '0.00'
                                    : '\$' +
                                        insuranceFee
                                            !.toStringAsFixed(2)
                                            .replaceAll("-", ""),
                                style: pw.TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                        : pw.Container(),
                    user == 'Guest'
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),
                    pw.Row(
                      children: [
                        pw.Text(
                          user == 'Guest' || bookingStatus == 'Cancelled'
                              ? 'Service Fee '
                              : 'Service Fee',
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        pw.Spacer(),
                        bookingStatus == 'Cancelled' && user == 'Host'
                            ? pw.Text(
                                '\$' '0.00',
                                style: pw.TextStyle(
                                  fontSize: 15,
                                ),
                              )
                            : pw.Text(
                                fee > 0
                                    ? '\$' + (fee.toStringAsFixed(2))
                                    : "0.00",
                                style: pw.TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                      ],
                    ),
                    pw.SizedBox(height: _textMargin),

                    ///pickup Fee//
                    bookingStatus != 'Cancelled' &&
                            latePickUpFee != null &&
                            latePickUpFee != 0
                        ? pw.Row(
                            children: [
                              user == 'Guest'
                                  ? pw.Text(
                                      "Pickup Fee",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  : pw.Text(
                                      "Pickup Credit",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              pw.Spacer(),
                              pw.Text(
                                  '${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                  )),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            latePickUpFee != null &&
                            latePickUpFee != 0
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    ///cleaning fee//
                    bookingStatus != 'Cancelled' &&
                            cleaningFee != null &&
                            cleaningFee != 0
                        ? pw.Row(
                            children: [
                              user == 'Guest'
                                  ? pw.Text(
                                      "Cleaning Fee",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  : pw.Text(
                                      "Cleaning Fee Credit",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              pw.Spacer(),
                              pw.Text(
                                  '${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                  )),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            cleaningFee != null &&
                            cleaningFee != 0
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    ///Extra mileage fee//
                    bookingStatus != 'Cancelled' &&
                            extraMileageFee != null &&
                            extraMileageFee != 0
                        ? pw.Row(
                            children: [
                              user == 'Guest'
                                  ? pw.Text("Extra Mileage Charge",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ))
                                  : pw.Text(
                                      "Extra Mileage Credit",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              pw.Spacer(),
                              pw.Text(
                                  '${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                  )),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            extraMileageFee != null &&
                            extraMileageFee != 0
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    /// fuel charge//
                    bookingStatus != 'Cancelled' &&
                            fuelChargeFee != null &&
                            fuelChargeFee != 0
                        ? pw.Row(
                            children: [
                              user == 'Guest'
                                  ? pw.Text(
                                      "Fuel Charge",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  : pw.Text(
                                      "Fuel Credit",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              pw.Spacer(),
                              pw.Text(
                                  '${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                  )),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            fuelChargeFee != null &&
                            fuelChargeFee != 0
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    /// toll  fee//
                    bookingStatus != 'Cancelled' &&
                            tollChargeFee != null &&
                            tollChargeFee != 0
                        ? pw.Row(
                            children: [
                              user == 'Guest'
                                  ? pw.Text(
                                      "Toll Fee",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  : pw.Text(
                                      "Toll Credit",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              pw.Spacer(),
                              pw.Text(
                                  '${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                  )),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            tollChargeFee != null &&
                            tollChargeFee != 0
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),

                    ///damage fee//
                    bookingStatus != 'Cancelled' &&
                            damageFee != null &&
                            damageFee != 0
                        ? pw.Row(
                            children: [
                              user == 'Guest'
                                  ? pw.Text(
                                      "Damage Fee",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  : pw.Text(
                                      "Damage Fee Credit",
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              pw.Spacer(),
                              pw.Text(
                                  '${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                  )),
                            ],
                          )
                        : pw.Container(),
                    bookingStatus != 'Cancelled' &&
                            damageFee != null &&
                            damageFee != 0
                        ? pw.SizedBox(height: _textMargin)
                        : pw.Container(),
                  ],
                ),
              )
            ]));
    pdf.addPage(pw.MultiPage(
        build: (pw.Context context) => <pw.Widget>[
              /// return fee//
              bookingStatus != 'Cancelled' &&
                      lateReturnFee != null &&
                      lateReturnFee != 0
                  ? pw.Row(
                      children: [
                        user == 'Guest'
                            ? pw.Text(
                                "Return Fee",
                                style: pw.TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            : pw.Text(
                                "Return Credit",
                                style: pw.TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                        pw.Spacer(),
                        pw.Text(
                            '${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
                            style: pw.TextStyle(
                              fontSize: 14,
                            )),
                      ],
                    )
                  : pw.Container(),
              bookingStatus != 'Cancelled' &&
                      lateReturnFee != null &&
                      lateReturnFee != 0
                  ? pw.SizedBox(height: _textMargin)
                  : pw.Container(),

              ///daily mileage//
              _receiptCarData['mileage'] != null &&
                      _receiptCarData["mileage"] == 'Limited'
                  ? pw.Row(
                      children: [
                        pw.Text(
                          '${_receiptCarData['mileageLimit']} Total Kilometers Per Day',
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
                    )
                  : pw.Row(
                      children: [
                        pw.Text(
                          'Unlimited Kilometers Per Day',
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
              pw.SizedBox(height: _textMargin),
              //coupon discount//
              user == 'Guest' &&
                      ridealikeCouponFee != 0 &&
                      couponAvailed == true
                  ? pw.Column(children: [
                      pw.Row(
                        children: [
                          pw.Text(
                            // 'Coupon Discount',
                            'RideAlike Discount',
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          pw.Spacer(),
                          pw.Text(
                            '\$' +
                                (ridealikeCouponFee
                                    !.toStringAsFixed(2)
                                    .replaceAll("-", "")),
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: _textMargin)
                    ])
                  : pw.Container(),

              ///cancellation//
              bookingStatus == 'Cancelled' &&
                      user == 'Guest' &&
                      (whoCancelled == 'Guest' ||
                          whoCancelled == 'Host' ||
                          whoCancelled == 'RideAlike')
                  ? pw.Column(children: [
                      pw.Row(
                        children: [
                          pw.Text(
                            receiptIndex == 0 ? 'Trip Total' : "Change Amount",
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          pw.Spacer(),
                          pw.Text(
                            '\$' +
                                ((total
                                    .toStringAsFixed(2)
                                    .replaceAll("-", ""))),
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      pw.SizedBox(height: _textMargin)
                    ])
                  : pw.Container(),

              ///trip cost or trip total without cancelled//
              bookingStatus != 'Cancelled'
                  ? pw.Column(children: [
                      pw.Row(
                        children: [
                          pw.Text(
                            user == 'Guest'
                                ? 'Grand Total'
                                : total > 0.0
                                    ? 'Grand Total Earnings'
                                    : 'Grand Total',
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          pw.Spacer(),
                          pw.Text(
                            '\$' +
                                (total.toStringAsFixed(2).replaceAll("-", "")),
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: _textMargin)
                    ])
                  : pw.Container(),

              bookingStatus == 'Cancelled'
                  ? whoCancelled == 'RideAlike'
                      ? pw.Column(children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                user == 'Guest'
                                    ? 'Cancellation Fee'
                                    : 'Host Cancellation Credit',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              pw.Spacer(),
                              _receiptData!.booking!.cancellationFee != null
                                  ? user == 'Guest'
                                      ? pw.Text(
                                          cancellationFee != null
                                              ? '\$' +
                                                  cancellationFee
                                                      .toStringAsFixed(2)
                                                      .replaceAll("-", "")
                                              : '\$' + '0.00',
                                          style: pw.TextStyle(
                                            fontSize: 14,
                                          ),
                                        )
                                      : pw.Text(
                                          _receiptData!.booking!.cancellationFee!
                                                          .cancellationProfit !=
                                                      null &&
                                                  whoGained != 'RideAlike'
                                              ? '\$' +
                                                  _receiptData
                                                      !.booking!
                                                      .cancellationFee!
                                                      .cancellationProfit!
                                                      .ammount!
                                                      .abs()
                                                      .toStringAsFixed(2)
                                              : '\$' + '0.00',
                                          style: pw.TextStyle(
                                            fontSize: 14,
                                          ),
                                        )
                                  : pw.Text(
                                      '0.00',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                            ],
                          ),
                          pw.SizedBox(height: _textMargin),
                        ])
                      : pw.Column(children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                user == whoPaid && whoPaid != 'Host'
                                    ? 'Cancellation Fee'
                                    : '$whoPaid Cancellation Fee',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              pw.Spacer(),
                              _receiptData!.booking!.cancellationFee != null
                                  ? pw.Text(
                                      cancellationFee != null
                                          ? '\$' +
                                              cancellationFee
                                                  .toStringAsFixed(2)
                                                  .replaceAll("-", "")
                                          : '\$' + '0.00',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ),
                                    )
                                  : pw.Text(
                                      '0.00',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                            ],
                          ),
                          pw.SizedBox(height: _textMargin),
                        ])
                  : pw.Container(),

              bookingStatus == 'Cancelled' &&
                      whoCancelled != 'RideAlike' &&
                      whoGained == user
                  ? pw.Column(
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              '$user Cancellation Credit',
                              style: pw.TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            pw.Spacer(),
                            _receiptData!.booking!.cancellationFee != null
                                ? pw.Text(
                                    _receiptData!.booking!.cancellationFee!
                                                .cancellationProfit!.ammount !=
                                            null
                                        ? '\$' +
                                            _receiptData!.booking!.cancellationFee!
                                                .cancellationProfit!.ammount!
                                                .toStringAsFixed(2)
                                                .replaceAll("-", "")
                                        : '\$' + '0.00',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                    ),
                                  )
                                : pw.Text(
                                    '0.00',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                          ],
                        ),
                        pw.SizedBox(height: _textMargin)
                      ],
                    )
                  : pw.Container(),
              bookingStatus == 'Cancelled' &&
                      user == 'Guest' &&
                      _receiptData!.booking!.cancellationFee!.refund != null
                  ? pw.Row(
                      children: [
                        pw.Text(
                          refund < 0 ? 'Trip Cost' : 'Trip Refund',
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        pw.Spacer(),
                        _receiptData!.booking!.cancellationFee != null
                            ? pw.Text(
                          _receiptData!.booking!.cancellationFee!.refund != null
                              ? '\$' +
                              (_receiptData
                              !.booking!.cancellationFee!.refund
                                  !.toStringAsFixed(2))
                                  .replaceAll("-", "")
                              : '\$' + '0.00',
                          style: pw.TextStyle(
                            fontSize: 15,
                          ),
                        )
                            : pw.Text(
                          '0.00',
                          style: pw.TextStyle(
                            fontSize: 15,
                            color: PdfColor.fromInt(0xff353B50),
                          ),
                        ),

                        // _receiptData!.booking!.cancellationFee != null
                        //     ? pw.Text(
                        //         _receiptData!.booking!.cancellationFee!.refund !=
                        //                 null
                        //             ? '\$' +
                        //                 (_receiptData
                        //                         !.booking!.cancellationFee!.refund
                        //                         .toStringAsFixed(2))
                        //                     .replaceAll("-", "")
                        //             : '\$' + '0.00',
                        //         style: pw.TextStyle(
                        //           fontSize: 15,
                        //         ),
                        //       )
                        //     : Text(
                        //         '0.00',
                        //         style: TextStyle(
                        //           fontFamily: 'Urbanist',
                        //           fontSize: 15,
                        //           color: Color(0xff353B50),
                        //         ),
                        //       ),
                      ],
                    )
                  : pw.Container(),
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
                  '2901 Bayview Ave, Suite 91117',
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
            ]));

    if (Platform.isIOS) {
      await Printing.sharePdf(
          bytes: pdf.save() as Uint8List, filename: 'ridealike_receipt.pdf');
      /* await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());*/
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

    final PdfImage assetImage =  PdfImage.file(
       pdf.document,
      bytes: (await rootBundle.load('images/Logo.png'))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            //margin: pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
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
                  'TRIP ID: ${'RBN$tripIdRBN'} ',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Text(
                  'TRIP DETAILS',
                  style: pw.TextStyle(
                    fontSize: 15,
                  ),
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    _bookingType!,
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    _receiptCarData['CarName'],
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
                    "Host",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    _receiptCarData['Host'],
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
                    "Guest",
                    style: pw.TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    _receiptCarData['Guest'],
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
                      "Booking Date",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      bookingDates!,
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                pw.Row(children: [
                  pw.Text(
                    receiptIndex == 0 ? "Pickup Date" : "Previous Pickup date",
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
                      receiptIndex == 0
                          ? "Return Date"
                          : "Previous return date",
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
                // receiptIndex==0?pw.SizedBox():pw.Column(
                //   children: [
                //     pw.Row(
                //       children: [
                //         pw.Text(
                //           "Updated Pickup date",
                //         ),
                //         pw.Text(
                //           pickupDate,
                //         ),
                //       ],
                //     ),
                //     pw.SizedBox(
                //       height: _textMargin,
                //     ),
                //     pw.Row(
                //
                //       children: [
                //         pw.Text(
                //           "Updated Return date",
                //         ),
                //         pw.Text(
                //         returnDate,
                //         ),
                //       ],
                //     ),
                //   ]
                ///start trip time
                bookingStatus != 'Cancelled' &&
                        tripIDValues != null &&
                        tripIDValues!.startedAt != null
                    ? pw.Row(
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
                bookingStatus != 'Cancelled' &&
                        tripIDValues != null &&
                        tripIDValues!.startedAt != null
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                ///end trip date
                bookingStatus != 'Cancelled' &&
                        tripIDValues != null &&
                        tripIDValues!.endedAt != null
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
                            endedTimeFormat.toString(),
                            style: pw.TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        tripIDValues != null &&
                        tripIDValues!.endedAt != null
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                bookingStatus == 'Cancelled' &&
                        _receiptData!.booking!.cancellationFee != null
                    ? pw.Row(
                        children: [
                          pw.Text(
                            "Cancelled Date",
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          pw.Spacer(),
                          pw.Text(
                            cancelledBookingDates!,
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : pw.Container(),
                bookingStatus == 'Cancelled' &&
                        _receiptData!.booking!.cancellationFee != null
                    ? pw.SizedBox(
                        height: _textMargin,
                      )
                    : pw.Container(),
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
                  'TRIP COST',
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
                      "Trip Rate",
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      rate,
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
                      'Trip Cost',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      bookingStatus == 'Cancelled' && user == 'Host'
                          ? '\$' '0.00'
                          : '\$' +
                              (price.toStringAsFixed(2).replaceAll("-", "")),
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: _textMargin,
                ),
                bookingStatus == 'Cancelled' && user == 'Host'
                    ? pw.Container()
                    : deliveryFee != null && deliveryFee != 0
                        ? pw.Column(children: [
                            pw.Row(
                              children: [
                                deliveryFeeString != null &&
                                        deliveryFeeString != ''
                                    ? pw.Text(
                                        'Delivery Fee ($deliveryFeeString)',
                                        style: pw.TextStyle(
                                          fontSize: 15,
                                        ),
                                      )
                                    : pw.Text(
                                        'Delivery Fee',
                                        style: pw.TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                pw.Spacer(),
                                pw.Text(
                                  '\$' +
                                      deliveryFee
                                          .toStringAsFixed(2)
                                          .replaceAll("-", ""),
                                  style: pw.TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: _textMargin)
                          ])
                        : pw.Container(),

                discountPercentage != null && discountPercentage != 0
                    ? pw.Column(children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              user == 'Guest'
                                  ? 'Guest Discount: ${discountPercentage!.toStringAsFixed(0)}% Off'
                                  : 'Host Discount: ${discountPercentage!.toStringAsFixed(0)}% Off',
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              '\$${discount.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: _textMargin)
                      ])
                    : pw.Container(),
                user == 'Guest'
                    ? pw.Row(
                        children: [
                          pw.Text(
                            'Insurance Fee',
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          pw.Spacer(),
                          pw.Text(
                            bookingStatus == 'Cancelled' && user == 'Host'
                                ? '\$' '0.00'
                                : '\$' +
                                    insuranceFee
                                        !.toStringAsFixed(2)
                                        .replaceAll("-", ""),
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : pw.Container(),
                user == 'Guest'
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),
                pw.Row(
                  children: [
                    pw.Text(
                      user == 'Guest' || bookingStatus == 'Cancelled'
                          ? 'Service fee '
                          : 'Service Fee',
                      style: pw.TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    pw.Spacer(),
                    bookingStatus == 'Cancelled' && user == 'Host'
                        ? pw.Text(
                            '\$' '0.00',
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          )
                        : pw.Text(
                            fee > 0 ? '\$' + (fee.toStringAsFixed(2)) : "0.00",
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                  ],
                ),
                pw.SizedBox(height: _textMargin),

                ///pickup Fee//
                bookingStatus != 'Cancelled' &&
                        latePickUpFee != null &&
                        latePickUpFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text(
                                  "Pickup Fee",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              : pw.Text(
                                  "Pickup Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        latePickUpFee != null &&
                        latePickUpFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                ///cleaning fee//
                bookingStatus != 'Cancelled' &&
                        cleaningFee != null &&
                        cleaningFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text(
                                  "Cleaning Fee",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              : pw.Text(
                                  "Cleaning Fee Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        cleaningFee != null &&
                        cleaningFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                ///Extra mileage fee//
                bookingStatus != 'Cancelled' &&
                        extraMileageFee != null &&
                        extraMileageFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text("Extra Mileage Charge",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ))
                              : pw.Text(
                                  "Extra Mileage Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        extraMileageFee != null &&
                        extraMileageFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                /// fuel charge//
                bookingStatus != 'Cancelled' &&
                        fuelChargeFee != null &&
                        fuelChargeFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text(
                                  "Fuel Charge",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              : pw.Text(
                                  "Fuel Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        fuelChargeFee != null &&
                        fuelChargeFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                /// toll  fee//
                bookingStatus != 'Cancelled' &&
                        tollChargeFee != null &&
                        tollChargeFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text(
                                  "Toll Fee",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              : pw.Text(
                                  "Toll Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        tollChargeFee != null &&
                        tollChargeFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                ///damage fee//
                bookingStatus != 'Cancelled' &&
                        damageFee != null &&
                        damageFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text(
                                  "Damage Fee",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              : pw.Text(
                                  "Damage Fee Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        damageFee != null &&
                        damageFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                /// return fee//
                bookingStatus != 'Cancelled' &&
                        lateReturnFee != null &&
                        lateReturnFee != 0
                    ? pw.Row(
                        children: [
                          user == 'Guest'
                              ? pw.Text(
                                  "Return Fee",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              : pw.Text(
                                  "Return Credit",
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                          pw.Spacer(),
                          pw.Text(
                              '${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
                              style: pw.TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      )
                    : pw.Container(),
                bookingStatus != 'Cancelled' &&
                        lateReturnFee != null &&
                        lateReturnFee != 0
                    ? pw.SizedBox(height: _textMargin)
                    : pw.Container(),

                //daily mileage//
                _receiptCarData['mileage'] != null &&
                        _receiptCarData["mileage"] == 'Limited'
                    ? pw.Row(
                        children: [
                          pw.Text(
                            '${_receiptCarData['mileageLimit']} Total Kilometers Per Day',
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
                      )
                    : pw.Row(
                        children: [
                          pw.Text(
                            'Unlimited Kilometers Per Day',
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
                pw.SizedBox(height: _textMargin),
                //coupon discount//
                user == 'Guest' &&
                        ridealikeCouponFee != 0 &&
                        couponAvailed == true
                    ? pw.Column(children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              // 'Coupon Discount',
                              'RideAlike Discount',
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              '\$' +
                                  (ridealikeCouponFee
                                      !.toStringAsFixed(2)
                                      .replaceAll("-", "")),
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: _textMargin)
                      ])
                    : pw.Container(),

                ///cancellation//
                bookingStatus == 'Cancelled' &&
                        user == 'Guest' &&
                        (whoCancelled == 'Guest' ||
                            whoCancelled == 'Host' ||
                            whoCancelled == 'RideAlike')
                    ? pw.Column(children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              'Grand Total',
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              '\$' +
                                  ((total
                                      .toStringAsFixed(2)
                                      .replaceAll("-", ""))),
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                        pw.SizedBox(height: _textMargin)
                      ])
                    : pw.Container(),

                ///trip cost or trip total without cancelled//
                bookingStatus != 'Cancelled'
                    ? pw.Column(children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              user == 'Guest'
                                  ? 'Grand Total'
                                  : total > 0.0
                                      ? 'Grand Total'
                                      : 'Grand Total',
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            pw.Spacer(),
                            pw.Text(
                              '\$' +
                                  (total
                                      .toStringAsFixed(2)
                                      .replaceAll("-", "")),
                              style: pw.TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: _textMargin)
                      ])
                    : pw.Container(),

                bookingStatus == 'Cancelled'
                    ? whoCancelled == 'RideAlike'
                        ? pw.Column(children: [
                            pw.Row(
                              children: [
                                pw.Text(
                                  user == 'Guest'
                                      ? 'Cancellation Fee'
                                      : 'Host Cancellation Credit',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                pw.Spacer(),
                                _receiptData!.booking!.cancellationFee != null
                                    ? user == 'Guest'
                                        ? pw.Text(
                                            cancellationFee != null
                                                ? '\$' +
                                                    cancellationFee
                                                        .toStringAsFixed(2)
                                                        .replaceAll("-", "")
                                                : '\$' + '0.00',
                                            style: pw.TextStyle(
                                              fontSize: 14,
                                            ),
                                          )
                                        : pw.Text(
                                            _receiptData!.booking!.cancellationFee
                                                            !.cancellationProfit !=
                                                        null &&
                                                    whoGained != 'RideAlike'
                                                ? '\$' +
                                                    _receiptData
                                                        !.booking
                                                        !.cancellationFee
                                                        !.cancellationProfit
                                                        !.ammount
                                                        !.abs()
                                                        .toStringAsFixed(2)
                                                : '\$' + '0.00',
                                            style: pw.TextStyle(
                                              fontSize: 14,
                                            ),
                                          )
                                    : pw.Text(
                                        '0.00',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                              ],
                            ),
                            pw.SizedBox(height: _textMargin),
                          ])
                        : pw.Column(children: [
                            pw.Row(
                              children: [
                                pw.Text(
                                  user == whoPaid && whoPaid != 'Host'
                                      ? 'Cancellation Fee'
                                      : '$whoPaid Cancellation Fee',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                pw.Spacer(),
                                _receiptData!.booking!.cancellationFee != null
                                    ? pw.Text(
                                        cancellationFee != null
                                            ? '\$' +
                                                cancellationFee
                                                    .toStringAsFixed(2)
                                                    .replaceAll("-", "")
                                            : '\$' + '0.00',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                        ),
                                      )
                                    : pw.Text(
                                        '0.00',
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                              ],
                            ),
                            pw.SizedBox(height: _textMargin),
                          ])
                    : pw.Container(),

                bookingStatus == 'Cancelled' &&
                        whoCancelled != 'RideAlike' &&
                        whoGained == user
                    ? pw.Column(
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                '$user Cancellation Credit',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              pw.Spacer(),
                              _receiptData!.booking!.cancellationFee != null
                                  ? pw.Text(
                                      _receiptData!.booking!.cancellationFee
                                                  !.cancellationProfit!.ammount !=
                                              null
                                          ? '\$' +
                                              _receiptData
                                                  !.booking
                                                  !.cancellationFee
                                                  !.cancellationProfit
                                                  !.ammount
                                                  !.toStringAsFixed(2)
                                                  .replaceAll("-", "")
                                          : '\$' + '0.00',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ),
                                    )
                                  : pw.Text(
                                      '0.00',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                            ],
                          ),
                          pw.SizedBox(height: _textMargin)
                        ],
                      )
                    : pw.Container(),
                bookingStatus == 'Cancelled' &&
                        user == 'Guest' &&
                        _receiptData!.booking!.cancellationFee!.refund != null
                    ? pw.Row(
                        children: [
                          pw.Text(
                            refund < 0 ? 'Trip Cost' : 'Trip Refund',
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          pw.Spacer(),
                          _receiptData!.booking!.cancellationFee != null
                              ? pw.Text(
                            _receiptData!.booking!.cancellationFee!.refund != null
                                ? '\$' +
                                (_receiptData!.booking!.cancellationFee!.refund
                                    !.toStringAsFixed(2))
                                    .replaceAll("-", "")
                                : '\$' + '0.00',
                            style: pw.TextStyle(
                              fontSize: 15,
                            ),
                          )
                              : pw.Text(
                            '0.00',
                            style: pw.TextStyle(
                              fontSize: 15,
                              color: PdfColor.fromInt(0xff353B50),
                            ),
                          ),

                        ],
                      )
                    : pw.Container(),

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
                    '2901 Bayview Ave, Suite 91117',
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
      /* await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());*/
    } else {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    }
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Latest Receipt"});
    Future.delayed(Duration.zero, () async {
      final Trips tripArgument = ModalRoute.of(context)!.settings.arguments as Trips;
      final String bookingID = tripArgument.bookingID!;
      receiptIndex = tripArgument.receiptIndex!;
      print("bookingId $bookingID");
      noOfChangeRequest = int.parse(tripArgument.noOfTripRequest!);

      var res = await fetchBookingData(bookingID);

      var res2 = await fetchCarDetails(
          json.decode(res.body!)['Booking']['Params']['CarID']);
      var _userIDs = [
        json.decode(res.body!)['Booking']['Params']['UserID'],
        tripArgument.hostUserID
      ];
      print("===========hostid$_userIDs");
      var tripID = json.decode(res.body!)['Booking']['TripID'];
      var res3 = await fetchUsersDetails(_userIDs);
      var resTripID = await getTripByID(tripID);
      if (resTripID != null) {
        tripIDValues = Trips.fromJson(json.decode(resTripID.body!)['Trip']);
        print('tripIDValues$tripIDValues');
      }
      print('tripID$resTripID');
      var endedAtTripTime = tripIDValues!.endedAt;
      var startedAtTripTime = tripIDValues!.startedAt;

      String guestName = "";
      String hostName = "";

      if (_userIDs[0] == json.decode(res3.body!)['Profiles'][0]['UserID']) {
        guestName = json.decode(res3.body!)['Profiles'][0]['FirstName'] +
            ' ' +
            json.decode(res3.body!)['Profiles'][0]['LastName'];
        hostName = json.decode(res3.body!)['Profiles'][1]['FirstName'] +
            ' ' +
            json.decode(res3.body!)['Profiles'][1]['LastName'];
      } else {
        guestName = json.decode(res3.body!)['Profiles'][1]['FirstName'] +
            ' ' +
            json.decode(res3.body!)['Profiles'][1]['LastName'];
        hostName = json.decode(res3.body!)['Profiles'][0]['FirstName'] +
            ' ' +
            json.decode(res3.body!)['Profiles'][0]['LastName'];
      }

      String? userID = await storage.read(key: 'user_id');

      if (userID != null) {
        if (userID == json.decode(res.body!)['Booking']['Params']['UserID']) {
          setState(() {
            user = 'Guest';
            _bookingType = 'Rental Car';
          });
        } else if (userID == json.decode(res2.body!)['Car']['UserID']) {
          setState(() {
            user = 'Host';
            _bookingType = 'Rent out Car';
          });
        }
      }

      setState(() {
        _receiptData =
            RentalBookingReceiptResponse.fromJson(json.decode(res.body!));
        tripID = _receiptData!.booking!.bookingID;
        tripIdRBN = _receiptData!.booking!.rBN!;
        pickupDate = DateFormat('EE MMM dd, hh:00 a').format(DateTime.parse(
                _receiptData!.booking!.params!.newStartDateTime![receiptIndex as int])
            .toLocal());

        returnDate = DateFormat('EE MMM dd, hh:00 a').format(DateTime.parse(
                (_receiptData!.booking!.params!.newEndDateTime![receiptIndex as int]))
            .toLocal());

        if (receiptIndex != 0) {
          previousPickupDate = DateFormat('EE MMM dd, hh:00 a').format(
              DateTime.parse(_receiptData
                      !.booking!.params!.newStartDateTime![receiptIndex! - 1])
                  .toLocal());
          previousReturnDate = DateFormat('EE MMM dd, hh:00 a').format(
              DateTime.parse((_receiptData
                      !.booking!.params!.newEndDateTime![receiptIndex! - 1]))
                  .toLocal());
        }

        locationName = _receiptData
            !.booking!
            .params!
            .returnLocation![
                receiptIndex as int]
            .address!;
        if (user == 'Guest' &&
            _receiptData!.booking!.newHostPricing![receiptIndex as int]
                    .tripDurationInString !=
                null) {
          List<String> rateInfo = (_receiptData
                  !.booking!.newPricing![receiptIndex as int].tripDurationInString)
              .split('@');
          rate = rateInfo[1];
          duration = rateInfo[0];
          if (receiptIndex != 0) {
            List<String> previousRateInfo = (_receiptData
                    !.booking!.newPricing![receiptIndex! - 1].tripDurationInString)
                .split('@');
            previousRate = previousRateInfo[1];
            previousDuration = previousRateInfo[0];
          }
        } else {
          List<String> rateInfo = (_receiptData
                  !.booking!.newHostPricing![receiptIndex as int].tripDurationInString)
              !.split('@');
          rate = rateInfo[1];
          duration = rateInfo[0];
          if (receiptIndex != 0) {
            List<String> previousRateInfo = (_receiptData!.booking
                    !.newHostPricing![receiptIndex! - 1].tripDurationInString)
                !.split('@');
            previousRate = previousRateInfo[1];
            previousDuration = previousRateInfo[0];
          }
        }

        if (user == 'Guest') {
          price = _receiptData!.booking!.newPricing![receiptIndex as int].tripPrice.abs();
        } else {
          price = _receiptData!.booking!.newHostPricing![receiptIndex as int].tripPrice!.abs();
        }
        if (user == 'Guest') {
          discount = _receiptData!.booking!.newPricing![receiptIndex as int].discount;
        } else {
          discount = _receiptData
              !.booking!.newHostPricing![receiptIndex as int].approvedDiscount!;
        }
        fee = user == 'Guest'
            ? _receiptData!.booking!.newPricing![receiptIndex as int].tripFee.abs()
            : _receiptData!.booking!.newHostPricing![receiptIndex as int].ridealikeFee;
        print("========fee $fee");
        insurance =
            _receiptData!.booking!.params!.insuranceType == 'Standard' ? 0 : 20;

        // total = user == 'Guest' ? _receiptData!.booking!.newPricing![receiptIndex as int].total : _receiptData!.booking!.hostPricing.total;

        bookingStatus = _receiptData!.booking!.bookingStatus!;
        cancellationFee = _receiptData!.booking!.cancellationFee != null
            ? _receiptData!.booking!.cancellationFee!.cancellationFee!
            : 0.0;
        cancellationFeeTotal = _receiptData!.booking!.cancellationFee != null
            ? _receiptData!.booking!.cancellationFee!.total!
            : 0.0;
        refund = _receiptData!.booking!.cancellationFee != null
            ? _receiptData!.booking!.cancellationFee!.refund!
            : 0.0;
        deliveryFee = user == 'Guest'
            ? _receiptData!.booking!.newPricing![receiptIndex as int].deliveryFee
            : _receiptData!.booking!.newHostPricing![receiptIndex as int].deliveryFee;
        deliveryFeeString = user == 'Guest'
            ? _receiptData!.booking!.newPricing![receiptIndex as int].deliveryRateInString
            : '';

        discountPercentage =
            _receiptData!.booking!.newPricing![receiptIndex as int].discountPercentage;
        insuranceFee =
            _receiptData!.booking!.newPricing![receiptIndex as int].insuranceFee;
        ridealikeCouponFee =
            _receiptData!.booking!.newPricing![receiptIndex as int].ridealikeCoupon;
        couponAvailed =
            _receiptData!.booking!.newPricing![receiptIndex as int].couponAvailed;
        hostRidealikeFee =
            _receiptData!.booking!.newHostPricing![receiptIndex as int].ridealikeFee!;
        bookingDates = DateFormat('EE MMM dd, hh:mm a')
            .format(DateTime.parse(_receiptData!.booking!.bookingDate!).toLocal());
        cancelledBookingDates = _receiptData!.booking!.cancellationFee != null
            ? DateFormat('EE MMM dd, hh:mm a').format(DateTime.parse(
                    _receiptData!.booking!.cancellationFee!.cancelledDate!)
                .toLocal())
            : '';
        whoCancelled = _receiptData!.booking!.cancellationFee != null
            ? _receiptData!.booking!.cancellationFee!.whoCancelled!
            : '';
        whoGained = _receiptData!.booking!.cancellationFee != null &&
                _receiptData!.booking!.cancellationFee!.cancellationProfit != null
            ? _receiptData!.booking!.cancellationFee!.cancellationProfit!.whoGained!
            : '';
        whoPaid = _receiptData!.booking!.cancellationFee != null &&
                _receiptData!.booking!.cancellationFee!.cancellationProfit != null
            ? _receiptData!.booking!.cancellationFee!.cancellationProfit!.whoPaid!
            : '';
        if (json.decode(res.body!) != null) {
          _receiptCarData = {
            "CarName": tripArgument.car == null ||
                    tripArgument.hostProfile!.verificationStatus == "Undefined"
                ? "Deleted Car"
                : json.decode(res2.body!)['Car']['About']['Year'] +
                    ' ' +
                    json.decode(res2.body!)['Car']['About']['Make'] +
                    ' ' +
                    json.decode(res2.body!)['Car']['About']['Model'],
            "Host": tripArgument.hostProfile!.verificationStatus == "Undefined"
                ? "Deleted Host Profile"
                : hostName,
            "Guest": tripArgument.guestProfile!.verificationStatus == "Undefined"
                ? "Deleted Guest Profile"
                : guestName,
            "mileage": tripArgument.car == null ||
                    tripArgument.hostProfile!.verificationStatus == "Undefined"
                ? "Undefined"
                : json.decode(res2.body!)['Car']['Preference']
                    ['DailyMileageAllowance'],
            "mileageLimit": tripArgument.car == null ||
                    tripArgument.hostProfile!.verificationStatus == "Undefined"
                ? "Undefined"
                : json.decode(res2.body!)['Car']['Preference']['Limit'],
          };
        }

        if (tripIDValues != null && tripIDValues!.endedAt != null) {
          endedTimeFormat = DateFormat('EE MMM dd, hh:mm a')
              .format(endedAtTripTime!.toLocal());
        }

        if (tripIDValues != null && tripIDValues!.startedAt != null) {
          startedTripIdTimeFormat = DateFormat('EE MMM dd, hh:mm a')
              .format(startedAtTripTime!.toLocal());
        }
        if (user == 'Guest') {
          if (tripIDValues != null &&
              tripIDValues!.otherFees != null &&
              tripIDValues!.otherFees!.latePickup != null) {
            latePickUpFee = tripIDValues!.otherFees!.latePickup!;
          }
        } else {
          if (tripIDValues != null &&
              tripIDValues!.otherFees != null &&
              tripIDValues!.otherFees!.hostProfit != null &&
              tripIDValues!.otherFees!.hostProfit!.latePickup != null) {
            latePickUpFee = tripIDValues!.otherFees!.hostProfit!.latePickup!;
          }
        }

        if (user == 'Guest') {
          if (tripIDValues != null &&
              tripIDValues!.otherFees != null &&
              tripIDValues!.otherFees!.lateReturn != null) {
            lateReturnFee = tripIDValues!.otherFees!.lateReturn!;
          }
        } else {
          if (tripIDValues != null &&
              tripIDValues!.otherFees != null &&
              tripIDValues!.otherFees!.hostProfit != null &&
              tripIDValues!.otherFees!.hostProfit!.lateReturn != null) {
            lateReturnFee = tripIDValues!.otherFees!.hostProfit!.lateReturn!;
          }
        }

        if (tripIDValues != null &&
            tripIDValues!.otherFees != null &&
            tripIDValues!.otherFees!.cleaning != null) {
          cleaningFee = tripIDValues!.otherFees!.cleaning!;
        }
        if (tripIDValues != null &&
            tripIDValues!.otherFees != null &&
            tripIDValues!.otherFees!.extraMileage != null) {
          extraMileageFee = tripIDValues!.otherFees!.extraMileage!;
        }
        if (tripIDValues != null &&
            tripIDValues!.otherFees != null &&
            tripIDValues!.otherFees!.fuelCharge != null) {
          fuelChargeFee = tripIDValues!.otherFees!.fuelCharge!;
        }
        if (tripIDValues != null &&
            tripIDValues!.otherFees != null &&
            tripIDValues!.otherFees!.toll != null) {
          tollChargeFee = tripIDValues!.otherFees!.toll!;
        }
        if (tripIDValues != null &&
            tripIDValues!.otherFees != null &&
            tripIDValues!.otherFees!.damage != null) {
          damageFee = tripIDValues!.otherFees!.damage!;
        }
        if (tripIDValues != null) {
          if (user == 'Guest') {
            total = double.tryParse(
                tripIDValues!.newGuestTotal![receiptIndex as int].toString())!;
            if (receiptIndex != 0) {
              previousTotal = double.tryParse(
                  tripIDValues!.newGuestTotal![receiptIndex! - 1].toString())!;
            }
          } else {
            total = double.tryParse(
                tripIDValues!.newHostTotal![receiptIndex as int].toString())!;
            if (receiptIndex != 0) {
              previousTotal = double.tryParse(
                  tripIDValues!.newHostTotal![receiptIndex! - 1].toString())!;
            }
          }
        }
        if (receiptIndex != 0) {
          print('previousDuration$previousDuration');
          print('Duration$duration');
          dayDifference = int.parse(previousDuration!.substring(0, 2)) -
              int.parse(duration!.substring(0, 2));
          print("$dayDifference ======daydiff");
          changeAmount = previousTotal! - total;
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
              if ((fuelChargeFee != null && fuelChargeFee != 0) ||
                  (tollChargeFee != null && tollChargeFee != 0) ||
                  (damageFee != null && damageFee != 0) ||
                  (cleaningFee != null && cleaningFee != 0)) {
                _printScreen();
              } else {
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
      body: _receiptData != null
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
                      Text(
                        'TRIP ID: ${'RBN$tripIdRBN'}',
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
                        'TRIP DETAILS',
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
                          Text(
                            _bookingType!,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          SizedText(
                            deviceWidth: SizeConfig.deviceWidth!,
                            textWidthPercentage: 0.5,
                            text: _receiptCarData['CarName'],
                            textAlign: TextAlign.right,
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            textColor: Color(0xff353B50),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Host',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            _receiptCarData['Host'],
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      //guest//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Guest',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            _receiptCarData['Guest'],
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      //booking dates//
                      _receiptData!.booking!.bookingDate != null
                          ? Row(
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
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.5,
                                  text: bookingDates!,
                                  textAlign: TextAlign.right,
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  textColor: Color(0xff353B50),
                                ),
                              ],
                            )
                          : Container(),
                      Divider(color: Color(0xFFE7EAEB)),

                      ///pickup date//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            receiptIndex == 0
                                ? 'Pickup Date'
                                : "Previous Pickup date",
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
                            text: receiptIndex == 0
                                ? pickupDate
                                : previousPickupDate,
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            textColor: Color(0xff353B50),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),

                      ///return date//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            receiptIndex == 0
                                ? 'Return Date'
                                : "Previous Return date",
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
                            text: receiptIndex == 0
                                ? returnDate
                                : previousReturnDate,
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            textColor: Color(0xff353B50),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),

                      receiptIndex == 0
                          ? SizedBox()
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Updated Pickup date",
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xffFF8F68),
                                      ),
                                    ),
                                    SizedText(
                                      deviceWidth: SizeConfig.deviceWidth!,
                                      textWidthPercentage: 0.5,
                                      textAlign: TextAlign.right,

                                      text:pickupDate,
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      textColor: Color(0xffFF8F68),
                                    ),
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Updated Return date",
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xffFF8F68),
                                      ),
                                    ),
                                    SizedText(
                                      deviceWidth: SizeConfig.deviceWidth!,
                                      textWidthPercentage: 0.5,
                                      textAlign: TextAlign.right,
                                      text: returnDate,
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      textColor: Color(0xffFF8F68),
                                    ),
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB)),
                              ],
                            ),

                      ///started Date time
                      _receiptData!.booking!.bookingStatus != 'Cancelled' &&
                              tripIDValues != null &&
                              tripIDValues!.startedAt != null
                          ? Row(
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
                          : Container(),
                      _receiptData!.booking!.bookingStatus != 'Cancelled' &&
                              (tripIDValues != null &&
                                  tripIDValues!.startedAt != null)
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      ///ended Date//
                      _receiptData!.booking!.bookingStatus != 'Cancelled' &&
                              tripIDValues != null &&
                              tripIDValues!.endedAt != null
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
                                  text: endedTimeFormat.toString(),
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  textColor: Color(0xff353B50),
                                ),
                              ],
                            )
                          : Container(),
                      _receiptData!.booking!.bookingStatus != 'Cancelled' &&
                              (tripIDValues != null &&
                                  tripIDValues!.endedAt != null)
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),
                      // //Cancelled Dates//
                      _receiptData!.booking!.bookingStatus == 'Cancelled' &&
                              _receiptData!.booking!.cancellationFee != null
                          ? Row(
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
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.45,
                                  textAlign: TextAlign.right,
                                  text: cancelledBookingDates!,
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  textColor: Color(0xff353B50),
                                ),
                              ],
                            )
                          : Container(),
                      _receiptData!.booking!.bookingStatus == 'Cancelled' &&
                              _receiptData!.booking!.cancellationFee != null
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),
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
                        'TRIP COST',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xff371D32).withOpacity(0.5),
                        ),
                      ),
                      Divider(color: Color(0xFFE7EAEB)),

                      //Trip rate//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Duration',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            duration!,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),
                      receiptIndex == 0
                          ? SizedBox()
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Updated Trip Duration',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xffFF8F68),
                                      ),
                                    ),
                                    Text(
                                      dayDifference!.isNegative
                                          ? "${dayDifference!.abs()} day(s) extended"
                                          : dayDifference == 0
                                              ? "N/A"
                                              : "$dayDifference day(s) reduced",
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xffFF8F68),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB))
                              ],
                            ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Rate',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            rate,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),

                      ///Trip cost//
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trip Cost',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32),
                            ),
                          ),
                          Text(
                            bookingStatus == 'Cancelled' && user == 'Host'
                                ? '\$' '0.00'
                                : '\$' + price.toStringAsFixed(2),
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xff353B50),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Color(0xFFE7EAEB)),

                      ///Delivery price//
                      bookingStatus == 'Cancelled' && user == 'Host'
                          ? Container()
                          : deliveryFee != null && deliveryFee != 0
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        deliveryFeeString != null &&
                                                deliveryFeeString != ''
                                            ? Text(
                                                'Delivery Fee ($deliveryFeeString)',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xff371D32),
                                                ),
                                              )
                                            : Text(
                                                'Delivery Fee',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xff371D32),
                                                ),
                                              ),
                                        Text(
                                          '\$' + deliveryFee.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xff353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(color: Color(0xFFE7EAEB))
                                  ],
                                )
                              : Container(),

                      ///discount//
                      discountPercentage != null && discountPercentage != 0
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      user == 'Guest'
                                          ? 'Guest Discount: ${discountPercentage!.toStringAsFixed(0)}% Off'
                                          : 'Host Discount: ${discountPercentage!.toStringAsFixed(0)}% Off',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                    Text(
                                      '\$${discount.toStringAsFixed(2).replaceAll("-", "")}',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xff353B50),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB))
                              ],
                            )
                          : Container(),

                      ///Insurance fee//
                      user == 'Guest'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Insurance Fee',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xff371D32),
                                  ),
                                ),
                                Text(
                                  bookingStatus == 'Cancelled' && user == 'Host'
                                      ? '\$' '0.00'
                                      : '\$' + insuranceFee!.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xff353B50),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      user == 'Guest'
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      ///rideAlike fee || service fee //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          user == 'Guest' || bookingStatus == 'Cancelled'
                              ? Text(
                                  'Service Fee',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xff371D32),
                                  ),
                                )
                              : Text(
                                  'Service Fee',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xff371D32),
                                  ),
                                ),
                          bookingStatus == 'Cancelled' && user == 'Host'
                              ? Text(
                                  '\$' '0.00',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xff353B50),
                                  ),
                                )
                              : Text(
                                  fee > 0
                                      ? '\$' + fee.toStringAsFixed(2)
                                      : '\$ 0.00',
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
                      bookingStatus != 'Cancelled' &&
                              latePickUpFee != null &&
                              latePickUpFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Late Pickup Fee'
                                      : 'Late Pickup Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${latePickUpFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              latePickUpFee != null &&
                              latePickUpFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      ///cleaning fee//
                      bookingStatus != 'Cancelled' &&
                              cleaningFee != null &&
                              cleaningFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Cleaning Fee'
                                      : 'Cleaning Fee Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${cleaningFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              cleaningFee != null &&
                              cleaningFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      ///Extra mileage fee//
                      bookingStatus != 'Cancelled' &&
                              extraMileageFee != null &&
                              extraMileageFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Extra Mileage Charge'
                                      : 'Extra Mileage Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${extraMileageFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              extraMileageFee != null &&
                              extraMileageFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      /// fuel charge//
                      bookingStatus != 'Cancelled' &&
                              fuelChargeFee != null &&
                              fuelChargeFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Fuel Charge'
                                      : 'Fuel Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${fuelChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              fuelChargeFee != null &&
                              fuelChargeFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      /// toll  fee//
                      bookingStatus != 'Cancelled' &&
                              tollChargeFee != null &&
                              tollChargeFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Toll Fee'
                                      : 'Toll Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${tollChargeFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              tollChargeFee != null &&
                              tollChargeFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      /// damage fee///
                      bookingStatus != 'Cancelled' &&
                              damageFee != null &&
                              damageFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Damage Fee'
                                      : 'Damage Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${damageFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              damageFee != null &&
                              damageFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),

                      /// return fee//
                      bookingStatus != 'Cancelled' &&
                              lateReturnFee != null &&
                              lateReturnFee != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: user == 'Guest'
                                      ? 'Late Return Fee'
                                      : 'Late Return Credit',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                    '${lateReturnFee.toStringAsFixed(2).replaceAll("-", "")}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xff353B50),
                                    )),
                              ],
                            )
                          : Container(),
                      bookingStatus != 'Cancelled' &&
                              lateReturnFee != null &&
                              lateReturnFee != 0
                          ? Divider(color: Color(0xFFE7EAEB))
                          : Container(),
                      //free mileage kilometer//
                      _receiptCarData['mileage'] != null &&
                              _receiptCarData["mileage"] == 'Limited'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text:
                                      '${_receiptCarData['mileageLimit']} Total Kilometers Per Day',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                  'Free',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xffFF8F68),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedText(
                                  deviceWidth: SizeConfig.deviceWidth!,
                                  textWidthPercentage: 0.7,
                                  text: 'Unlimited Kilometers Per Day',
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  textColor: Color(0xff371D32),
                                ),
                                Text(
                                  'Free',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xffFF8F68),
                                  ),
                                ),
                              ],
                            ),
                      Divider(color: Color(0xFFE7EAEB)),
                      //rideAlikeCouponFee//
                      user == 'Guest' &&
                              ridealikeCouponFee != 0 &&
                              couponAvailed == true
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      // 'Coupon Discount',
                                      'RideAlike Discount',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                    Text(
                                      '\$' +
                                          ridealikeCouponFee!.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xff353B50),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB))
                              ],
                            )
                          : Container(),

                      //trip total//
                      // bookingStatus!='Cancelled' && user=='Guest'&& ridealikeCouponFee!=0 && couponAvailed==true? :Container(),
                      bookingStatus == 'Cancelled' &&
                              user == 'Guest' &&
                              (whoCancelled == 'Guest' ||
                                  whoCancelled == 'Host' ||
                                  whoCancelled == 'RideAlike')
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      receiptIndex == 0
                                          ? "Trip Total"
                                          : 'Change Amount',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                    //    _receiptData!.booking!.cancellationFee!=null &&    _receiptData!.booking!.cancellationFee!=''?
                                    Text(
                                      '\$' +
                                          (total
                                              .toStringAsFixed(2)
                                              .replaceAll("-", "")),
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    )
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB))
                              ],
                            )
                          : Container(),
                      //trip total without cancellation//

                      bookingStatus != 'Cancelled'
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      user == 'Guest' && receiptIndex == 0
                                          ? 'Trip Total'
                                          : total > 0.0
                                              ? 'Total Trip Earnings'
                                              : 'Change Amount',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                    Text(
                                      '\$' +
                                          (receiptIndex == 0
                                              ? total
                                                  .toStringAsFixed(2)
                                                  .replaceAll("-", "")
                                              : changeAmount
                                                  !.toStringAsFixed(2)
                                                  .replaceAll("-", "")),
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                  thickness: receiptIndex == noOfChangeRequest
                                      ? 3.0
                                      : 0.0,
                                ),
                              ],
                            )
                          : Container(),

                      receiptIndex == noOfChangeRequest
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Grand Total',
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 24,
                                          color: Color(0xff371D32),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$' +
                                          (total
                                              .toStringAsFixed(2)
                                              .replaceAll("-", "")),
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(),

                      //cancelled fee info//
                      bookingStatus == 'Cancelled'
                          ? whoCancelled == 'RideAlike'
                              ? Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        user == 'Guest'
                                            ? 'Cancellation Fee'
                                            : 'Host Cancellation Credit',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xff371D32),
                                        ),
                                      ),
                                      _receiptData!.booking!.cancellationFee !=
                                              null
                                          ? user == 'Guest'
                                              ? Text(
                                                  cancellationFee != null
                                                      ? '\$' +
                                                          cancellationFee
                                                              .toStringAsFixed(
                                                                  2)
                                                              .replaceAll(
                                                                  "-", "")
                                                      : '\$' + '0.00',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xff353B50),
                                                  ),
                                                )
                                              : Text(
                                                  _receiptData
                                                                  !.booking
                                                                  !.cancellationFee
                                                                  !.cancellationProfit !=
                                                              null &&
                                                          whoGained !=
                                                              'RideAlike'
                                                      ? '\$' +
                                                          _receiptData
                                                              !.booking
                                                              !.cancellationFee
                                                              !.cancellationProfit
                                                              !.ammount
                                                              !.toStringAsFixed(
                                                                  2)
                                                              .replaceAll(
                                                                  "-", "")
                                                      : '\$' + '0.00',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xff353B50),
                                                  ),
                                                )
                                          : Text(
                                              '0.00',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xff353B50),
                                              ),
                                            ),
                                    ],
                                  ),
                                  Divider(color: Color(0xFFE7EAEB)),
                                ])
                              : Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        user == whoPaid && whoPaid != 'Host'
                                            ? 'Cancellation Fee'
                                            : '$whoPaid Cancellation Fee',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xff371D32),
                                        ),
                                      ),
                                      _receiptData!.booking!.cancellationFee !=
                                              null
                                          ? Text(
                                              cancellationFee != null
                                                  ? '\$' +
                                                      cancellationFee
                                                          .toStringAsFixed(2)
                                                          .replaceAll("-", "")
                                                  : '\$' + '0.00',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xff353B50),
                                              ),
                                            )
                                          : Text(
                                              '0.00',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xff353B50),
                                              ),
                                            ),
                                    ],
                                  ),
                                  Divider(color: Color(0xFFE7EAEB)),
                                ])
                          : Container(),

                      bookingStatus == 'Cancelled' &&
                              whoCancelled != 'RideAlike' &&
                              whoGained == user
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$user Cancellation Credit',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                      ),
                                    ),
                                    _receiptData!.booking!.cancellationFee != null
                                        ? Text(
                                            _receiptData
                                                        !.booking
                                                        !.cancellationFee
                                                        !.cancellationProfit
                                                        !.ammount !=
                                                    null
                                                ? '\$' +
                                                    _receiptData
                                                        !.booking
                                                        !.cancellationFee
                                                        !.cancellationProfit
                                                        !.ammount
                                                        !.toStringAsFixed(2)
                                                : '\$' + '0.00',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xff353B50),
                                            ),
                                          )
                                        : Text(
                                            '0.00',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xff353B50),
                                            ),
                                          ),
                                  ],
                                ),
                                Divider(color: Color(0xFFE7EAEB))
                              ],
                            )
                          : Container(),

                      //
                      // bookingStatus=='Cancelled'&& user=='Host' && whoCancelled=='Guest'
                      //     ||(user=='Guest' ||user=='Host' &&whoCancelled=='Host')?Container():  Divider(color: Color(0xFFE7EAEB)),
                      // //cancellation fee//
                      // bookingStatus=='Cancelled' && whoCancelled!='Ridealike'?
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(user=='Guest' && whoCancelled=='Guest'?
                      //         'Cancellation Fee':
                      //      user=='Host' &&whoCancelled=='Guest'? 'Guest Cancellation Fee':
                      //      (user=='Guest' ||user=='Host' &&whoCancelled=='Host')?'Host Cancellation Fee':'',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 16,
                      //         color: Color(0xff371D32),
                      //       ),
                      //     ),
                      //
                      //     _receiptData!.booking!.cancellationFee!=null?
                      //     Text(
                      //       cancellationFee!=null?
                      //       '\$' + cancellationFee.toStringAsFixed(2):'\$'+'0.00',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 14,
                      //         color: Color(0xff353B50),
                      //       ),
                      //     ):
                      //     Text('0.00'
                      //       ,style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 14,
                      //         color: Color(0xff353B50),
                      //       ),
                      //     ),
                      //   ],
                      // ):Container(),
                      // bookingStatus=='Cancelled'&&
                      // user=='Host' &&whoCancelled=='Guest'||  user=='Guest' &&whoCancelled=='Host'?
                      // Divider(color: Color(0xFFE7EAEB)):Container(),
                      // bookingStatus=='Cancelled' &&
                      // user=='Host' &&whoCancelled=='Guest'?
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       'Host Cancellation Credit',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 16,
                      //         color: Color(0xff371D32),
                      //       ),
                      //     ),
                      //
                      //     _receiptData!.booking!.cancellationFee!=null ?
                      //     Text(_receiptData!.booking!.cancellationFee!.cancellationProfit!=null ?
                      //       '\$' + ( _receiptData!.booking!.cancellationFee!.cancellationProfit.ammount.toStringAsFixed(2)):'\$'+'0.00',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 14,
                      //         color: Color(0xff353B50),
                      //       ),
                      //     ):
                      //     Text('0.00',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 14,
                      //         color: Color(0xff353B50),
                      //       ),
                      //     ),
                      //   ],
                      // ):
                      // user=='Guest' &&whoCancelled=='Host'? Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       'Guest Cancellation Credit',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 16,
                      //         color: Color(0xff371D32),
                      //       ),
                      //     ),
                      //
                      //     _receiptData!.booking!.cancellationFee!=null
                      //         ?
                      //     Text(
                      //       _receiptData!.booking!.cancellationFee!.cancellationProfit!=null
                      //
                      //           ?
                      //       '\$' + ( _receiptData!.booking!.cancellationFee!.cancellationProfit.ammount.toStringAsFixed(2)):'\$'+'0.00',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 14,
                      //         color: Color(0xff353B50),
                      //       ),
                      //     ):
                      //     Text('0.00',
                      //       style: TextStyle(
                      //         fontFamily: 'Urbanist',
                      //         fontSize: 14,
                      //         color: Color(0xff353B50),
                      //       ),
                      //     ),
                      //   ],
                      // ):Container(),

                      //trip refund//
                      bookingStatus == 'Cancelled' &&
                              user == 'Guest' &&
                              refund != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  refund < 0 ? 'Trip Cost ' : 'Trip Refund ',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xff371D32),
                                  ),
                                ),
                                _receiptData!.booking!.cancellationFee != null
                                    ? Text(
                                        refund != null
                                            ? '\$' +
                                                (refund.toStringAsFixed(2))
                                                    .replaceAll("-", "")
                                            : '\$' + '0.00',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xff353B50),
                                        ),
                                      )
                                    : Text(
                                        '0.00',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xff353B50),
                                        ),
                                      ),
                              ],
                            )
                          : Container(),
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
                            '2901 Bayview Ave, Suite 91117',
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
    //cancellation trip total//
  }
}
