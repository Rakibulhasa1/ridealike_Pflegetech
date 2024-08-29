import 'package:flutter/material.dart';
import 'package:ridealike/pages/list_a_car/bloc/car_preference_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/daily_mileage_configuration_response.dart';
import 'package:ridealike/utils/empty_cheker.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../../utils/app_events/app_events_utils.dart';

class SetCarRulesUi extends StatefulWidget {
  @override
  State createState() => SetCarRulesUiState();
}

class SetCarRulesUiState extends  State<SetCarRulesUi> {
  var carPreferenceBloc=CarPreferenceBloc();
  bool exitPressed = false;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Setup Car Rules"});
  }

  @override
  Widget build (BuildContext context) {
    Map routeData= ModalRoute.of(context)!.settings.arguments as Map;
    CreateCarResponse createCarResponse = CreateCarResponse.fromJson((routeData['carResponse'] as CreateCarResponse).toJson());

    double deviceWidth = MediaQuery.of(context).size.width;

    var purpose =routeData['purpose'];
    bool pushNeeded = routeData['PUSH']==null? false: routeData['PUSH'];
    String? pushRouteName = routeData['ROUTE_NAME'];
    // final  CreateCarResponse createCarResponse = ModalRoute.of(context).settings.arguments;

    carPreferenceBloc.callFetchDailyMileageConfiguration().then((value) {
      if (value == null){
        value = FetchDailyMileageConfigurationResponse(listCarConfigurables:
        ListCarConfigurables(dailyMileageAllowanceLimitRange: DailyMileageAllowanceLimitRange(min: 300, max: 1000), swapWithinMaxLimit: 300));
      }

      carPreferenceBloc.changedDailyMileageConfig.call(value);

      if (createCarResponse.car!.preference!.completed==false){
        if(isEmptyString(createCarResponse.car!.preference!.dailyMileageAllowance!)){
          createCarResponse.car!.preference!.dailyMileageAllowance='Limited';
        }
        if(isEmpty(createCarResponse.car!.preference!.limit!)){
          createCarResponse.car!.preference!.limit = 400;
        }
        if(createCarResponse.car!.preference!.listingType!.rentalEnabled == false &&  createCarResponse.car!.preference!.listingType!.swapEnabled==false) {
          createCarResponse.car!.preference!.listingType!.rentalEnabled = true;
          createCarResponse.car!.preference!.listingType!.swapEnabled = true;
        }
      }

      if(createCarResponse.car!.preference!.limit!< value.listCarConfigurables!.dailyMileageAllowanceLimitRange!.min! ||
          createCarResponse.car!.preference!.limit!> value.listCarConfigurables!.dailyMileageAllowanceLimitRange!.max!){
        createCarResponse.car!.preference!.limit = value.listCarConfigurables!.dailyMileageAllowanceLimitRange!.min!;

      }
      carPreferenceBloc.changedCarPreferenceData.call(createCarResponse);

      // here
      carPreferenceBloc.changedCarPreferenceData.call(createCarResponse);
      carPreferenceBloc.changedProgressIndicator.call(0);
    });

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            if( pushNeeded){
              Navigator.pushNamed(context, pushRouteName!, arguments:
              {'carResponse': routeData['carResponse'],'purpose':purpose});
            } else {
              Navigator.pop(context);
            }
          }
        ),
        centerTitle: true,
        title: Text('4/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<CreateCarResponse>(
            stream: carPreferenceBloc.carPreferenceData,
            builder: (context, carPreferenceDataSnapshot) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      if(!exitPressed){
                        exitPressed = true;
                        var response = await carPreferenceBloc.carPreferences(carPreferenceDataSnapshot.data!
                            , completed: false, saveAndExit: true);
                        Navigator.pushNamed(context, '/dashboard_tab',arguments:response);

                      }

                    },
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.only(right: 16),
                        child:
                        createCarResponse.car!.preference!.completed! ?
                  Text(''):
                 Text('Save & Exit',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Color(0xFFFF8F62),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: StreamBuilder<CreateCarResponse>(
        stream: carPreferenceBloc.carPreferenceData,
        builder: (context, carPreferenceDataSnapshot) {
          return carPreferenceDataSnapshot.hasData && carPreferenceDataSnapshot.data!=null?
      Container(
            child: new SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  child: Text('Set preferences for your vehicle',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 36,
                                        color: Color(0xFF371D32),
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset('icons/Info_Car-Rules.png'),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Smoking
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Smoking allowed?',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton(

                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                padding: EdgeInsets.all(16.0),

                                                backgroundColor: carPreferenceDataSnapshot.data!.car!.preference!.isSmokingAllowed! ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                              ), onPressed: () {
                                              carPreferenceDataSnapshot.data!.car!.preference!.isSmokingAllowed= true;
                                              carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);
                                            },
                                                 child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('YES',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 12,
                                                          color: carPreferenceDataSnapshot.data!.car!.preference!.isSmokingAllowed!  ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(

                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                padding: EdgeInsets.all(16.0),
                                                backgroundColor: carPreferenceDataSnapshot.data!.car!.preference!.isSmokingAllowed!  ? Color(0xFFE0E0E0).withOpacity(0.5) : Color(0xFFFF8F62),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                              ),
                                              onPressed: () {
                                                carPreferenceDataSnapshot.data!.car!.preference!.isSmokingAllowed= false;
                                                carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                              },
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('NO',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 12,
                                                          color: carPreferenceDataSnapshot.data!.car!.preference!.isSmokingAllowed!  ? Color(0xFF353B50).withOpacity(0.5) : Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Pets
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text('Suitable for pets?',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                padding: EdgeInsets.all(16.0),
                                                backgroundColor: carPreferenceDataSnapshot.data!.car!.preference!.isSuitableForPets! ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                              ),
                                              onPressed: () {

                                                  carPreferenceDataSnapshot.data!.car!.preference!.isSuitableForPets= true;
                                                  carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                              },
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('YES',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 12,
                                                          color:carPreferenceDataSnapshot.data!.car!.preference!.isSuitableForPets!? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                padding: EdgeInsets.all(16.0),
                                                backgroundColor: carPreferenceDataSnapshot.data!.car!.preference!.isSuitableForPets! ? Color(0xFFE0E0E0).withOpacity(0.5) : Color(0xFFFF8F62),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),


                                              ),
                                              onPressed: () {

                                                carPreferenceDataSnapshot.data!.car!.preference!.isSuitableForPets = false;
                                                carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                              },
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('NO',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 12,
                                                          color:  carPreferenceDataSnapshot.data!.car!.preference!.isSuitableForPets!? Color(0xFF353B50).withOpacity(0.5) : Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Daily mileage
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('Daily mileage allowance?',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: <Widget>[
                                                Text("Set a daily mileage limit and if your Guest exceeds this limit, you will be able to charge an extra fee for every additional kilometer.",
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                padding: EdgeInsets.all(16.0),
                                                backgroundColor:  carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance== 'Unlimited' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                              ),
                                              onPressed: () {

                                                carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance = 'Unlimited';
                                                carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                              },
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('UNLIMITED',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 12,
                                                          color:  carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance == 'Unlimited' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                padding: EdgeInsets.all(16.0),
                                                backgroundColor: carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance  == 'Limited' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                              ),
                                              onPressed: () {

                                                carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance = 'Limited';
                                                carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                              },
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Text('SET A LIMIT',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 12,
                                                          color:   carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance == 'Limited' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Limit
                    StreamBuilder<FetchDailyMileageConfigurationResponse>(
                        stream: carPreferenceBloc.dailyMileageConfig,
                        builder: (context, dailyMileageConfigSnapshot) {
                          return dailyMileageConfigSnapshot.hasData && dailyMileageConfigSnapshot.data!=null?
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: new BorderRadius.circular(8.0),
                                        ),
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedText(
                                                      deviceWidth: deviceWidth,
                                                      textWidthPercentage: 0.6,
                                                      text: "What should be the limit?",
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      textColor: Color(0xFF371D32),
                                                    ),
                                                    Text('${carPreferenceDataSnapshot.data!.car!.preference!.limit} KM',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(0xFF353B50),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: SliderTheme(
                                                        data: SliderThemeData(
                                                          thumbColor: Color(0xffFFFFFF),
                                                          trackShape: RoundedRectSliderTrackShape(),
                                                          trackHeight: 4.0,
                                                          activeTrackColor: Color(0xffFF8F62),
                                                          inactiveTrackColor: Color(0xFFE0E0E0),
                                                          tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                          activeTickMarkColor: Color(0xffFF8F62),
                                                          inactiveTickMarkColor: Color(0xFFE0E0E0),
                                                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                        ),
                                                        child: Slider(
                                                          min: double.parse(dailyMileageConfigSnapshot.data!.listCarConfigurables!.dailyMileageAllowanceLimitRange!.min.toString()),
                                                          max: double.parse(dailyMileageConfigSnapshot.data!.listCarConfigurables!.dailyMileageAllowanceLimitRange!.max.toString()),
                                                          onChanged:   carPreferenceDataSnapshot.data!.car!.preference!.dailyMileageAllowance == 'Limited' ? (values) {
                                                            carPreferenceDataSnapshot.data!.car!.preference!.limit = values.toInt();
                                                            carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);
                                                          } : null,
                                                          value: double.parse(carPreferenceDataSnapshot.data!.car!.preference!.limit.toString())<double.
                                                          parse(dailyMileageConfigSnapshot.data!.listCarConfigurables!.dailyMileageAllowanceLimitRange!.min.toString())?

                                                          double.parse(dailyMileageConfigSnapshot.data!.listCarConfigurables!.dailyMileageAllowanceLimitRange!.min.toString()):
                                                          double.parse(carPreferenceDataSnapshot.data!.car!.preference!.limit.toString()),
                                                          divisions: 7,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ):Container();
                        }
                    ),
                    SizedBox(height: 30),
                    // Select listing type
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Text('Select a type of listing for your vehicle',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    color: Color(0xFF371D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Rental only
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: new BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              height: 26,
                                              width: 26,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                                border: Border.all(
                                                  color: Color(0xFF353B50),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(7.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: carPreferenceDataSnapshot.data!.car!.preference!.listingType!.rentalEnabled! && !carPreferenceDataSnapshot.data!.car!.preference!.listingType!.swapEnabled! ? Color(0xFFFF8F62) : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Rental only',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          carPreferenceDataSnapshot.data!.car!.preference!.listingType!.rentalEnabled=true;
                                          carPreferenceDataSnapshot.data!.car!.preference!.listingType!.swapEnabled=false;
                                          carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                          // _checkButtonDisability();
                                        },
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        child: Text('Your vehicle will be available for rentals and you are not looking for another vehicle in exchange.',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Swap only
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: new BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              height: 26,
                                              width: 26,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                                border: Border.all(
                                                  color: Color(0xFF353B50),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(7.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: carPreferenceDataSnapshot.data!.car!.preference!.listingType!.swapEnabled! && !carPreferenceDataSnapshot.data!.car!.preference!.listingType!.rentalEnabled! ? Color(0xFFFF8F62) : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Swap only',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          carPreferenceDataSnapshot.data!.car!.preference!.listingType!.rentalEnabled=false;
                                          carPreferenceDataSnapshot.data!.car!.preference!.listingType!.swapEnabled=true;
                                          carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                        },
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        child: Text('Your vehicle will only be available when another host has a vehicle to offer for exchange.',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Rental & Swap
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: new BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              height: 26,
                                              width: 26,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                                border: Border.all(
                                                  color: Color(0xFF353B50),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(7.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: carPreferenceDataSnapshot.data!.car!.preference!.listingType!.swapEnabled! &&
                                                        carPreferenceDataSnapshot.data!.car!.preference!.listingType!.rentalEnabled! ? Color(0xFFFF8F62) : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text('Both rental and swap',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          carPreferenceDataSnapshot.data!.car!.preference!.listingType!.rentalEnabled=true;
                                          carPreferenceDataSnapshot.data!.car!.preference!.listingType!.swapEnabled=true;
                                          carPreferenceBloc.changedCarPreferenceData.call( carPreferenceDataSnapshot.data!);

                                        },
                                      ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        child: Text('Your vehicle will be available for both rental and swap.',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Next button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: StreamBuilder<int>(
                                  stream: carPreferenceBloc.progressIndicator,
                                  builder: (context, progressIndicatorSnapshot) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFFF8F62),
                                        padding: EdgeInsets.all(16.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),


                                      ),
                                        onPressed: progressIndicatorSnapshot.data== 1? null:() async {
                                        carPreferenceBloc.changedProgressIndicator.call(1);
                                        var response = await carPreferenceBloc.carPreferences(carPreferenceDataSnapshot.data!);
                                        if(response!=null){
                                          if( pushNeeded){
                                            Navigator.pushNamed(context, pushRouteName!, arguments:
                                            {'carResponse': response,'purpose':purpose});
                                          } else {
                                            Navigator.pop(
                                                context,
                                                response);
                                          }
                                        }

                                      },
                                      child: progressIndicatorSnapshot.data== 0?
                                      Text('Next',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 18,
                                            color: Colors.white
                                        ),
                                      ): SizedBox(
                                        height: 18.0,
                                        width: 18.0,
                                        child: new CircularProgressIndicator(strokeWidth: 2.5),
                                      ) ,
                                    );
                                  }
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ):      Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(strokeWidth: 2.5)
              ],
            ),
          );
        }
      ),
    );
  }
}


