import 'package:flutter/material.dart';

import '../../widgets/insurance_policy_bullet_point.dart';
import 'booking_info.dart';



class BookingInsurance extends StatefulWidget {
  final bookingInfo;

  BookingInsurance({this.bookingInfo});

  @override
  State createState() => BookingInsuranceState(bookingInfo);
}

class BookingInsuranceState extends  State<BookingInsurance> {
  var bookingInfo;

  BookingInsuranceState(this.bookingInfo);

  void handleShowBookingInfoModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return BookingInfo(
          bookingInfo: bookingInfo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 1.5,
          maxHeight: MediaQuery.of(context).size.height - 24,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          // height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(10),
            //   topRight: Radius.circular(10),
            // ),
          ),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            shrinkWrap: true,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text("Insurance",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF371D32),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
                    ),
                  ],
                ),
              ),
              // Standard
              Padding(
                padding: EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      bookingInfo['insuranceType'] = 'Minimum';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: bookingInfo['insuranceType'] != 'Standard' ? Border.all(width: 1.0, color: const Color(0xFFEA9A62)) : Border.all(color: Colors.transparent),
                      color: bookingInfo['insuranceType'] == 'Standard' ? Color(0xffF2F2F2) : Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Standard',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              InsurancePolicyBulletPoint('\$2,000,000 Third Party Liability'),
                              InsurancePolicyBulletPoint('Standard Accident Benefits'),
                              InsurancePolicyBulletPoint('\$1,000 Deductible for All Perils'),
                              InsurancePolicyBulletPoint('Up to \$1,500 for transportation replacement'),
                              InsurancePolicyBulletPoint('No depreciation on new vehicles'),
                            ],
                          ),
                        ),
                        bookingInfo['insuranceType'] != 'Standard' ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 16,
                              child: Icon(
                                  Icons.check,
                                  color: Color(0xFFEA9A62)
                              ),
                            ),
                          ],
                        ) : new Container(),
                      ],
                    ),
                  ),
                ),
              ),
              // Premium
              Padding(
                padding: EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      bookingInfo['insuranceType'] = 'Standard';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: bookingInfo['insuranceType'] == 'Standard' ? Border.all(width: 1.0, color: const Color(0xFFEA9A62)) : Border.all(color: Colors.transparent),
                      color: bookingInfo['insuranceType'] != 'Standard' ? Color(0xffF2F2F2) : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Premium',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              InsurancePolicyBulletPoint('\$2,000,000 Third Party Liability'),
                              InsurancePolicyBulletPoint('Standard Accident Benefits'),
                              InsurancePolicyBulletPoint('\$0 Deductible for All Perils'),
                              InsurancePolicyBulletPoint('Up to \$1,500 for transportation replacement'),
                              InsurancePolicyBulletPoint('No depreciation on new vehicles'),
                            ],
                          ),
                        ),
                        bookingInfo['insuranceType'] == 'Standard' ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 16,
                              child: Icon(
                                Icons.check,
                                color: Color(0xFFEA9A62)
                              ),
                            ),
                          ],
                        ) : new Container(),
                      ],
                    ),
                  ),
                ),
              ),

              // SizedBox(height: 5),
              // Padding(
              //   padding: const EdgeInsets.only(right: 16, left: 16),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Text('No thanks, I’d like to decline damage protection',
              //         style: TextStyle(
              //           fontFamily: 'Urbanist',
              //           fontSize: 12,
              //           color: Color(0xFFEA9A62),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Divider(),
              Padding(
                padding: EdgeInsets.only(right:16, left: 16, bottom: 16, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xffFF8F68),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                              ),
                              onPressed: () => handleShowBookingInfoModal(),
                              child: Text('Save',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
