import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_events/app_events_utils.dart';
import '../../utils/url_launcher.dart';

const textStyle = TextStyle(
  fontFamily: 'Urbanist',
  fontSize: 16,
  color: Color(0xFF371D32),
);
const hyperLinkTextStyle = TextStyle(
  fontFamily: 'Urbanist',
  fontSize: 16,
  color: Color(0xFF0000EE),
);

void launchUrl(String url) async {
  if (await canLaunch(url)) {
    launch(url);
  } else {
    throw "Could not launch $url";
  }
}

class SubmitClaim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Submit Claim"});
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xffFF8F68),
        ),
        centerTitle: true,
        title: Text(
          'Submit a claim',
          style: TextStyle(
              color: Color(0xff371D32), fontSize: 20, fontFamily: 'Urbanist'),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 8, bottom: 10),
                  child: Text('If you are in an accident:',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 28,
                          color: Color(0xFF371D32),
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1.',
                      style: textStyle,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: AutoSizeText(
                        'As required by law, collect the other driver\'s full name, Driver\'s License number, full address and phone number.  Also collect the same information for any passengers in either vehicle.',
                        style: textStyle,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2.',
                      style: textStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: AutoSizeText(
                        'Contact local police for guidance on having them attend the accident scene, or attending the nearest Collision Reporting Center, to obtain a police report of the damage.',
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. ',
                      style: textStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: AutoSizeText(
                        'Advise RideAlike of the details above, via email to hello@ridealike.com',
                        style: textStyle,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4. ',
                      style: textStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: AutoSizeText(
                        'Advise the Host of the accident details.',
                        style: textStyle,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5.',
                      style: textStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: AutoSizeText(
                          'Contact Northbridge if a claim is required.',
                          style: textStyle),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                    'Also note that if a tow is required, ensure you contact Roadside Assistance at 1-647-321-7433 and use their services to minimize your costs.',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFF371D32),
                        fontWeight: FontWeight.normal)),
                SizedBox(
                  height: 20,
                ),
                Text('Helpful Information:',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 28,
                        color: Color(0xFF371D32),
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10,
                ),
                Text('Northbridge Insurance can be reached at: 1-855-621-6262',
                    style: textStyle),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  child: Text('Claims to Northbridge can be submitted here',
                      style: hyperLinkTextStyle),
                  onTap: () {
                    UrlLauncher.launchUrl(northBridgeSubmittedUrl);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  child: Text(
                      'RideAlike\'s Policy (CBC 0675939) can be found here',
                      style: hyperLinkTextStyle),
                  onTap: () {
                    UrlLauncher.launchUrl(rideAlikePoliciesCBCurl);
                  },
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
