import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/create_a_profile/bloc/create_profile_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/password_error_class.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateProfileUI extends StatefulWidget {
  @override
  _CreateProfileUIState createState() => _CreateProfileUIState();
}

class _CreateProfileUIState extends State<CreateProfileUI> {
  var createProfileBloc = CreateProfileBloc();
  bool _hidePassword = true;
  FocusNode _focusNode = FocusNode();
  bool _hasValidated = false;
  bool _termsAndCondition = true;
  bool _promotionalMaterials = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _testController = TextEditingController();
  TextEditingController _firstController = TextEditingController(text: "");
  TextEditingController _lastController = TextEditingController(text: "");
  TextEditingController? _controller;
  String? txt;
  int _counter = 0;

  Widget _buildErrorMessages(List<PasswordError> errors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Please enter a valid password',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 12,
            color: Color(0xFFF55A51),
          ),
        ),
        SizedBox(height: 5),
        for (var error in errors)
          Row(
            children: [
              Icon(
                error.valid ? Icons.check_circle : Icons.clear,
                color: error.valid ? Color(0xFF5CAEAC) : Color(0xFFF55A51),
              ),
              SizedBox(width: 5),
              Text(
                error.message,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 12,
                  color: error.valid ? Color(0xFF5CAEAC) : Color(0xFFF55A51),
                ),
              ),
            ],
          ),
      ],
    );
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("registration_view");
    _controller = new TextEditingController(text: '');
    createProfileBloc.changedNextButton.call(true);
  }

  @override
  Widget build(BuildContext context) {
    createProfileBloc.changedTerms.call(_termsAndCondition);
    createProfileBloc.changedPromotionalMaterials.call(_promotionalMaterials);
    createProfileBloc.changedError.call('');
    createProfileBloc.changedProgressIndicator.call(0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xffFF8F68),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            //Navigator.pushNamed(context, '/create_profile_or_sign_in');
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      /*appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            //Navigator.pushNamed(context, '/create_profile_or_sign_in');
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),*/
      body: StreamBuilder<bool>(
        stream: createProfileBloc.nextButton,
        builder: (context, nextButtonSnapshot) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/signup_top.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 25,
                          ),
                          Text(
                            "Create account",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontFamily: 'Urbanist'),
                          ),
                        ],
                      ),
                    ) // Foreground widget here
                    ),

                //Bloc UI started//
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          StreamBuilder<String>(
                            stream: createProfileBloc.firstName,
                            builder: (context, snapshot) {
                              print(snapshot.data);
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data != _firstController.text) {
                                _firstController.text = snapshot.data!;
                                _firstController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _firstController.text.length));
                              }
                              return TextFormField(
                                controller: _firstController,
                                onChanged: (value) {
                                  if (value.length > 100) {
                                    value = value.substring(0, 100);
                                  }
                                  createProfileBloc.changedFirstName(value);
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z ]'),
                                      replacementString: ''),
                                ],
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    // Adjust the font size as needed
                                    color: Colors
                                        .grey, // You can customize the color as well
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xffFF8F68)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xffFF8F68)),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 10, right: 2, top: 10),
                                  labelText: 'First Name',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.account_box_outlined,
                                    color: Color(0xffFF8F68),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      flex: 1,
                      child: StreamBuilder<String>(
                          stream: createProfileBloc.lastName,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data != _lastController.text) {
                              _lastController.text = snapshot.data!;
                              _lastController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _lastController.text.length));
                            }

                            return TextFormField(
                              controller: _lastController,
                              onChanged: (value) {
                                if (value.length > 100) {
                                  value = value.substring(0, 100);
                                }
                                createProfileBloc.changedLastName(value);
                              },
                              textCapitalization: TextCapitalization.sentences,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    (RegExp('[a-zA-Z ]')),
                                    replacementString: '')
                              ],
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  // Adjust the font size as needed
                                  color: Colors
                                      .grey, // You can customize the color as well
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffFF8F68)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffFF8F68)),
                                ),
                                contentPadding: EdgeInsets.only(
                                  left: 10,
                                  right: 2,
                                  top: 10,
                                ),
                                labelText: 'Last Name',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.account_box_outlined,
                                  color: Color(0xffFF8F68),
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: StreamBuilder<String>(
                      stream: createProfileBloc.email,
                      builder: (context, emailSnapshot) {
                        return Column(
                          children: [
                            TextField(
                              autocorrect: false,
                              onChanged: createProfileBloc.changedEmail,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9@._-]'),
                                    replacementString: '')
                              ],
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  // Adjust the font size as needed
                                  color: Colors
                                      .grey, // You can customize the color as well
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffFF8F68)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffFF8F68)),
                                ),
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 10),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xffFF8F68),
                                ),
                              ),
                            ),
                            emailSnapshot.hasError
                                ? SizedBox(height: 5)
                                : Container(),
                            emailSnapshot.hasError
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('${emailSnapshot.error}.',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFFF55A51),
                                        )),
                                  )
                                : Container(),
                          ],
                        );
                      }),
                ),
                SizedBox(height: 20),
                //Password//
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: StreamBuilder<String>(
                      stream: createProfileBloc.password,
                      builder: (context, passwordSnapshot) {
                        return Column(
                          children: [
                            TextField(
                              focusNode: _focusNode,
                              onChanged: (password) {
                                setState(() {
                                  _hasValidated = true;
                                });
                                createProfileBloc.changedPasswordWithValidation(
                                    password, passwordSnapshot.hasError);
                              },
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: Colors
                                      .grey,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffFF8F68)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xffFF8F68)),
                                ),
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 15, bottom: 10),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xffFF8F68),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xff353B50),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            if (_hasValidated)
                              if (passwordSnapshot.hasError && ((passwordSnapshot.error) as List<PasswordError>).isNotEmpty)
                                _buildErrorMessages(passwordSnapshot.error as List<PasswordError>)
                              else if (!passwordSnapshot.hasError && passwordSnapshot.data!.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'You have a strong password',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 15,
                                      color: Color(0xFF5CAEAC),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      }),
                ),
                SizedBox(height: 10),
                // Terms & Conditions
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: StreamBuilder<bool>(
                      stream: createProfileBloc.terms,
                      builder: (context, snapshot) {
                        return GestureDetector(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 26,
                                  width: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      color: Color(0xFF353B50),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 22,
                                    color: _termsAndCondition
                                        ? Color(0xFFFF8F68)
                                        : Colors.transparent,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xFF353B50),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: 'I agree to RideAlike ',
                                                ),
                                                TextSpan(
                                                  text: 'Terms & Conditions',
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          launchUrl(
                                                              termsOfServiceUrl);
                                                        },
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(text: ','),
                                                TextSpan(
                                                  text: ' Privacy Policy',
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          launchUrl(
                                                              privacyPolicyUrl);
                                                        },
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(text: ' and '),
                                                TextSpan(
                                                  text: 'Code of Conduct.',
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          launchUrl(
                                                              codeOfConductUrl);
                                                        },
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              _termsAndCondition = !_termsAndCondition;
                              createProfileBloc.changedTerms
                                  .call(_termsAndCondition);
                            });
                      }),
                ),
                SizedBox(height: 20),
//            // Promotional Materials
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: StreamBuilder<bool>(
                      stream: createProfileBloc.promotionalMaterials,
                      builder: (context, snapshot) {
                        return GestureDetector(
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 26,
                                width: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: Color(0xFF353B50),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 22,
                                  color: _promotionalMaterials
                                      ? Color(0xFFFF8F68)
                                      : Colors.transparent,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'I agree to receive promotional materials and product updates.',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _promotionalMaterials = !_promotionalMaterials;
                            createProfileBloc.changedPromotionalMaterials
                                .call(_promotionalMaterials);
                          },
                        );
                      }),
                ),
                SizedBox(height: 40),
                // Next button
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  width: double.maxFinite,
                  child: StreamBuilder<bool>(
                    stream: createProfileBloc.button,
                    builder: (context, snapshot) {
                      return StreamBuilder<int>(
                        stream: createProfileBloc.progressIndicator,
                        builder: (context, progressIndicatorSnapshot) {
                          return ElevatedButton(
                            onPressed: nextButtonSnapshot.hasData &&
                                    nextButtonSnapshot.data! &&
                                    progressIndicatorSnapshot.data == 0
                                ? () async {
                                    if (progressIndicatorSnapshot.data == 0) {
                                      createProfileBloc.changedProgressIndicator
                                          .call(1);
                                      CreateProfileResponse? argument =
                                          await createProfileBloc
                                              .submitButton();
                                      print('name${argument!.user!.firstName}');
                                      AppEventsUtils.logEvent(
                                          "registration_added_name_email",
                                          params: {
                                            "source": "Email",
                                            "first_name":
                                                argument.user!.firstName,
                                            "last_name":
                                                argument.user!.lastName,
                                            "email": argument.user!.email,
                                          });
                                      createProfileBloc.changedProgressIndicator
                                          .call(0);

                                      if (argument != null) {
                                        final snackBar = SnackBar(
                                          content: Text(
                                              'A verification link has been sent to your email address.'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        // _scaffoldKey.currentState
                                        //     .showSnackBar(snackBar);
                                        Future.delayed(Duration(seconds: 3),
                                            () {
                                          Navigator.pushNamed(context,
                                                  '/verify_phone_number_ui',
                                                  arguments: argument)
                                              .then((value) {
                                            createProfileBloc.changedNextButton
                                                .call(true);
                                          });
                                        });
                                      } else {
                                        createProfileBloc.changedNextButton
                                            .call(true);
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              backgroundColor:
                                  nextButtonSnapshot.hasData && snapshot.data!
                                      ? Color(0xffFF8F68)
                                      : Colors.grey,
                            ),
                            child: progressIndicatorSnapshot.hasData &&
                                    progressIndicatorSnapshot.data == 1
                                ? SizedBox(
                                    height: 18.0,
                                    width: 18.0,
                                    child: new CircularProgressIndicator(
                                        strokeWidth: 2.5),
                                  )
                                : Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.white),
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                        color: Color(0xffFF8F68),
                        thickness: 1,
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Or ",
                          style:
                              TextStyle(fontSize: 18, fontFamily: 'Urbanist')),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Divider(
                        thickness: 1,
                        color: Color(0xffFF8F68),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  width: double.maxFinite,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signin_ui');
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
