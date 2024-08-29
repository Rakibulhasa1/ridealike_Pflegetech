import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart' as location_handler;
import 'package:ridealike/pages/search_a_car/front_search.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';
import 'package:ridealike/pages/search_a_car/search_car_by_type.dart';
import 'package:ridealike/pages/search_a_car/search_car_tab.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class DiscoverRentHello extends StatefulWidget {
  SearchTabState? object;

  // DiscoverRentHello({super.key});
  @override
  _DiscoverRentHelloState createState() => _DiscoverRentHelloState();
}

class _DiscoverRentHelloState extends State<DiscoverRentHello> {
  bool locationFetched = false;

  bool dataFetched = false;
  bool showLocation = false;
  var currentAddressValue;
  bool locationGetSuccess = false;

  List<String> _selectedCarTypes = [];

  location_handler.PermissionStatus? locationPermission;

  @override
  Widget build(BuildContext context) {
    final SearchData? receivedData =
        ModalRoute.of(context)?.settings.arguments as SearchData?;

    if (receivedData != null && dataFetched == false) {
      dataFetched = true;
      List temp = receivedData.carType!;
      if (temp != null) {
        for (var i in temp) {
          _selectedCarTypes.add(i);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FrontSearch(),
            Padding(
              padding: const EdgeInsets.only(left:8.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'svg/Group.svg',
                  ),
                  SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Verified Guests and Hosts',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            // Add space between the image and the description
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Everyone on RideAlike undergoes a thorough identity and driving history review, ensuring a secure and reliable experience.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Browse By Car',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarSearchByType(image: 'images/economy.png', type: 'Economy Car'),
                  CarSearchByType(
                      image: 'images/mid.png', type: 'Mid/Full Size Car'),
                  CarSearchByType(image: 'images/suv.png', type: 'SUV'),
                  CarSearchByType(
                      image: 'images/sports.png', type: 'Sports Car'),
                  CarSearchByType(
                      image: 'images/minivan.png', type: 'Mini Van'),
                  CarSearchByType(image: 'images/van.png', type: 'Van'),
                  CarSearchByType(
                      image: 'images/Truck.png', type: 'Pickup Truck'),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:12.0),
                  child: SvgPicture.asset(
                    'svg/insurance.svg',
                  ),
                ),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hassle-free Insurance',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            // Add space between the image and the description
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'At RideAlike, we have partnered with North bridge Insurance, a trusted Canadian-owned name for over a century, to offer you \$2 million in liability coverage. Your peace of mind is our priority.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:12.0),
                  child: SvgPicture.asset(
                    'svg/247.svg',
                    // width: 24,
                    // height: 24,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '24/7 Roadside Assistance',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'We\'ve got your back on the open road. Flat tire? Fuel trouble? Locked out? We\'ve got you covered.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:12.0),
                  child: SvgPicture.asset(
                    'svg/rideswap.svg',
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'RideSwap',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'And here\'s where we truly stand out. Rent a car with ease, backed by hassle-free insurance. Have an idle car? Let it effortlessly earn for you on our platform. But the real magic happens when you seamlessly swap your car for another - a unique feature exclusive to RideAlike.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            SizedBox(height: 75),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //AppEventsUtils.logEvent("discover_rent_hello");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Discover Rent Hello"});
  }
}
