import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridealike/pages/create_a_profile/bloc/verify_phone_number_bloc.dart';
import 'package:ridealike/pages/create_a_profile/response_model/add_phone_number_response.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
class VerifyPhoneNumberUi extends StatefulWidget {
  State createState() => new VerifyPhoneNumberUiState();
}



class VerifyPhoneNumberUiState extends State<VerifyPhoneNumberUi> {
  final verifyPhoneNubBloc = VerifyPhoneNumberBloc();

  @override
  void initState() {
    super.initState();
    verifyPhoneNubBloc.changedNextButton.call(true);
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Verify Phone Number"});
  }

  String dropdownValue = '+1';

  @override
  Widget build(BuildContext context) {
    final CreateProfileResponse createProfileResponse = ModalRoute.of(context)!.settings.arguments as CreateProfileResponse;

    verifyPhoneNubBloc.changedDropdownValue.call(dropdownValue);
    verifyPhoneNubBloc.changedProgressIndicator.call(0);

    print('rcvd$createProfileResponse');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            //Navigator.pushNamed(context, '/create_profile');
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
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
                              child: Text(
                                'Verify your mobile number',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 36,
                                    color: Color(0xFF371D32),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset('icons/Phone_Verify-Number.png'),
                  ],
                ),
                SizedBox(height: 20),
                // Text
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              child: Text(
                                'Mobile number is required so we know how to contact you in case of emergency.',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFF353B50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Input fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            // height: 70.0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: StreamBuilder<String>(
                                  stream: verifyPhoneNubBloc.dropDown,
                                  builder: (context, snapshot) {
                                    return  Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child:
                                      CountryCodePicker(flagWidth: 20,
                                        alignLeft: true,
                                        initialSelection: "+1",
                                        comparator: (a, b) {
                                          return a.name!.compareTo(b.name!);
                                        },
                                        onChanged: (_value) {
                                          print("Selected country code: $_value");
                                          dropdownValue = _value.toString();
                                          verifyPhoneNubBloc.changedDropdownValue.call(_value.toString());
                                        },),

                                    );
                                    //   DropdownButtonFormField<String>(
                                    //   isDense: true,
                                    //   decoration: InputDecoration(
                                    //     contentPadding: EdgeInsets.all(16.0),
                                    //     border: InputBorder.none,
                                    //     labelText: 'Country',
                                    //     labelStyle: TextStyle(
                                    //       fontFamily: 'Urbanist',
                                    //       fontSize: 12,
                                    //       color: Color(0xFF353B50),
                                    //     ),
                                    //   ),
                                    //   value: dropdownValue,
                                    //   icon: Icon(Icons.keyboard_arrow_down,
                                    //       color: Color(0xFF353B50)),
                                    //   onChanged: (_value) {
                                    //     verifyPhoneNubBloc.changedDropdownValue
                                    //         .call(_value);
                                    //   },
                                    //   items: <String>['+1', '+91', '+880']
                                    //       .map<DropdownMenuItem<String>>(
                                    //           (String item) {
                                    //     return DropdownMenuItem<String>(
                                    //       value: item,
                                    //       child: Text(item),
                                    //     );
                                    //   }).toList(),
                                    // );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      flex: 7,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: StreamBuilder<String>(
                                  stream: verifyPhoneNubBloc.phoneNumber,
                                  builder: (context, snapshot) {
                                    return TextField(
                                      onChanged: (phoneNumber) {
                                        verifyPhoneNubBloc.changedPhoneNumber.call(phoneNumber);
                                        if (phoneNumber.length == 10) {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                        }
                                      },
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(14.0),
                                          border: InputBorder.none,
                                          labelText: 'Mobile number',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 12,
                                            color: Color(0xFF353B50),
                                          ),
                                          hintText: 'Enter mobile number',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14, // Adjust the font size as needed
                                            color: Colors.grey, // You can customize the color as well
                                          ),
                                          counterText: ""),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 120),
                // Next button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: StreamBuilder<bool>(
                                stream: verifyPhoneNubBloc.nextAddPhoneButton,
                                builder: (context, snapshot) {
                                  return StreamBuilder<bool>(
                                      stream: verifyPhoneNubBloc.button,
                                      builder: (context, buttonSnapshot) {
                                        return StreamBuilder<int>(
                                            stream: verifyPhoneNubBloc
                                                .progressIndicator,
                                            builder: (context,
                                                progressIndicatorSnapshot) {
                                              return ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: snapshot.hasData &&
                                                      buttonSnapshot.data!
                                                      ? Color(0xffFF8F68)
                                                      : Colors.grey,
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                                ),
                                                  onPressed: snapshot.hasData && progressIndicatorSnapshot.data == 0 ? () async {
                                                          if (progressIndicatorSnapshot.data == 0) {
                                                            verifyPhoneNubBloc.changedProgressIndicator.call(1);
                                                            AddPhoneNumberResponse arguments = await verifyPhoneNubBloc.addPhone(createProfileResponse);
                                                            AppEventsUtils.logEvent("registration_added_phone_number",
                                                                params: {"phoneNb": arguments.profile!.phoneNumber,
                                                                }
                                                            );
                                                            if (arguments != null && arguments.status!.success == true) {
                                                              createProfileResponse.user!.phoneNumber = arguments.profile!.phoneNumber;

                                                              Navigator.pushNamed(context, '/verify_security_code_ui',
                                                                arguments: createProfileResponse,
                                                              ).then((value) {
                                                                verifyPhoneNubBloc.changedNextButton.call(true);
                                                                verifyPhoneNubBloc.changedProgressIndicator.call(0);

                                                              });
                                                            }
                                                            else {
                                                              verifyPhoneNubBloc.changedNextButton.call(true);
                                                              verifyPhoneNubBloc.changedProgressIndicator.call(0);

                                                            }
                                                          }
                                                        }
                                                      : null,



                                                  child: progressIndicatorSnapshot
                                                              .hasData &&
                                                          progressIndicatorSnapshot
                                                                  .data ==
                                                              1
                                                      ? SizedBox(
                                                          height: 18.0,
                                                          width: 18.0,
                                                          child:
                                                              new CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2.5),
                                                        )
                                                      : Text(
                                                          'Next',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white),
                                                        ));
                                            });
                                      });
                                }),
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
      ),
    );
  }
}
