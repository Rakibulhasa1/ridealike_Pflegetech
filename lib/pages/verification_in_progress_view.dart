import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VerificationInProgressView extends StatelessWidget {
  final storage = new FlutterSecureStorage();

  @override
  Widget build (BuildContext context){
    final Map _receivedData = ModalRoute.of(context)!.settings.arguments  as Map;

    return Scaffold(
      backgroundColor: Colors.white,
      
      body: PageView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Image.asset('icons/Verification-in-Progress.png'),
                SizedBox(height: 60),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text('Verification in progress',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 30,
                              color: Color(0xFF371D32),
                            ),
                          ),
                        ],
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
                          Text("It may take up to 1 business day to verify your profile. We'll send you a message once it's reveiwed and approved.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70),
                Row(
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
                              onPressed: () async {
                                await storage.delete(key: 'profile_id');
                                await storage.delete(key: 'user_id');
                                // await storage.delete(key: 'user_emailId');
                                await storage.write(key: 'profile_id', value: _receivedData['Verification']['ProfileID'].toString());
                                await storage.write(key: 'user_id', value:  _receivedData['Verification']['UserID'].toString());

                                Navigator.pushNamed(
                                  context,
                                  '/profile'
                                );
                              },
                              child: Text('Ok',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 18,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}