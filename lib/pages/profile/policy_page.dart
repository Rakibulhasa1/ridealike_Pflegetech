import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/utils/url_launcher.dart';
import 'package:ridealike/widgets/profile_page_block.dart';

class PolicyPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xffFF8F68),
        ),
        centerTitle: true,
        title: Text('Policies & Insurance',
          style: TextStyle(
              color: Color(0xff371D32), fontSize: 20, fontFamily: 'Urbanist'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            ProfilePageBlock(text: 'Terms of Service', onPressed: (){
              UrlLauncher.launchUrl(termsOfServiceUrl);
            },),
            SizedBox(height: 10,),

            ProfilePageBlock(text: 'Privacy Policy', onPressed: (){
              UrlLauncher.launchUrl(privacyPolicyUrl);
            },),
            SizedBox(height: 10,),

            ProfilePageBlock(text: 'Code of conduct', onPressed: (){
              UrlLauncher.launchUrl(codeOfConductUrl);
            },),
            SizedBox(height: 10,),

            ProfilePageBlock(text: 'Covid Checklist', onPressed: (){
              UrlLauncher.launchUrl(covidChecklist);
            },),
            SizedBox(height: 10,),

            ProfilePageBlock(text: 'Insurance Policy', onPressed: (){
              UrlLauncher.launchUrl(insurancePolicyUrl);
            },),
          ],
        ),
      ),
    );
  }
}
