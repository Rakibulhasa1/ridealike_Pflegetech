import 'package:flutter/material.dart';

import '../widgets/insurance_policy_bullet_point.dart';
import '../widgets/insurance_policy_text.dart';

class InsurancePolicy extends StatelessWidget {
  @override
  Widget build (BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text('Insurance Policy',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xff371D32),
            ),
          ),
          elevation: 0.0,
        ),

      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Coverage',
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
                ],
              ),
              SizedBox(height: 15),

              InsurancePolicyText('You choose your protection package with each trip:\n'),
              InsurancePolicyBulletPoint('Standard protection with \$1000 deductible'),
              InsurancePolicyBulletPoint('Premium protection with \$0 deductible\n'),

              InsurancePolicyText('Whatever protection level you choose, you are covered with '
                '\$2,000,000 Third Party Liability insurance. In addition, the coverage '
                'from RideAlike’s insurance partner includes the following features:\n'),
              InsurancePolicyBulletPoint('Standard Accident Benefits'),
              InsurancePolicyBulletPoint('Up to \$1,500 for transportation replacement'),
              InsurancePolicyBulletPoint('No depreciation on new vehicles'),
            ],
          ),
        ),
      ),
    );
  }
}