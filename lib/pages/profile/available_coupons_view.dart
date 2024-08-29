import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/available_coupon_shimmer.dart';
import '../book_a_car/booking_info.dart';
import '../book_a_car/coupon_response/coupon_response.dart';


class AvailableCouponView extends StatefulWidget {

  @override
  _AvailableCouponViewState createState() => _AvailableCouponViewState();
}
class _AvailableCouponViewState extends State<AvailableCouponView> {

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateFormat formatter = DateFormat('d MMMM yyyy');
    return formatter.format(date);
  }

  Widget _couponTextView(Coupon coupon) {
    final textStyle = TextStyle(
      fontSize: 11,
      color: Colors.black,
      fontFamily: 'Urbanist',
    );
    if (coupon.percentageDiscount > 0 &&
        coupon.numberOfDaysDiscount == 0 &&
        coupon.amount == 0) {
      return Text(
        'Minimum \$${coupon.rentalAmountRequired} rental cost \nMinimum ${coupon.rentalDaysRequired} day(s) rental \n${coupon.percentageDiscount}% off up to \$${coupon.maxAmountDiscount}',
        style: textStyle,
      );
    } else if (coupon.percentageDiscount == 0 &&
        coupon.numberOfDaysDiscount > 0 &&
        coupon.amount == 0) {
      return Text(
        'Minimum \$${coupon.rentalAmountRequired} rental cost \nMinimum ${coupon.rentalDaysRequired} day(s) rental \nMaximum Discount \$${coupon.maxAmountDiscount}',
        style: textStyle,
      );
    } else if (coupon.percentageDiscount == 0 &&
        coupon.numberOfDaysDiscount == 0 &&
        coupon.amount > 0) {
      return Text(
        'Minimum \$${coupon.rentalAmountRequired} rental cost \nMinimum ${coupon.rentalDaysRequired} day(s) rental',
        style: textStyle,
      );
    } else {
      return Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Available coupons',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            color: Color(0xFF353B50),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(left:12.0,right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                FutureBuilder<ApiResponse>(
                  future: fetchCoupons(
                      carId,userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CouponShimmerEffect());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading coupons'));
                    } else if (!snapshot.hasData || snapshot.data!.coupons.isEmpty) {
                      return Center(
                        child: Text(
                          'No Coupons Found',
                          style: TextStyle(
                            color: Color(0xff353B50),
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: snapshot.data!.coupons.map((coupon) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(35, 10, 15, 15),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/Group 15.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      coupon.couponCode,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                    Text(
                                      coupon.numberOfDaysDiscount > 0
                                          ? '${coupon.numberOfDaysDiscount} days OFF'
                                          : (coupon.percentageDiscount == 0
                                          ? '\$${coupon.amount} OFF'
                                          : '${coupon.percentageDiscount}% OFF'),
                                      style: TextStyle(
                                        color: Color(0xff353B50),
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                _couponTextView(coupon),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 20,
                                      width: MediaQuery.of(context).size.width/3,
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Color(0xffFF8F68),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Use by ${coupon.validTill}',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

