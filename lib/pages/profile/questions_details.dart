import 'package:flutter/material.dart';
import 'package:ridealike/pages/profile/response_service/faq_profile_response.dart';

class FAQsQuestionsDetails extends StatefulWidget {
  @override
  _FAQsQuestionsDetailsState createState() => _FAQsQuestionsDetailsState();
}

class _FAQsQuestionsDetailsState extends State<FAQsQuestionsDetails> {
  @override
  Widget build(BuildContext context) {
    FAQ faqQuestion = ModalRoute.of(this.context)!.settings.arguments as FAQ;
    var headingTextStyle = TextStyle(
        color: Color(0xff371D32),
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Urbanist',
        letterSpacing: -0.2);
    var textStyle=TextStyle(fontSize: 16,fontFamily: 'Urbanist',
        fontWeight: FontWeight.normal,color: Color(0xff371D32),letterSpacing: -0.5,height: 1.4);
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        title: Center(
            child: Text(
          'FAQs',
          style: TextStyle(
              color: Color(0xff371D32),
              fontSize: 16,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500),
        )),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        '${faqQuestion.question}',
                        style: headingTextStyle,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15,),
                Align(alignment: Alignment.centerLeft,
                    child: Text(faqQuestion.explanation!,
                      style:textStyle ,)),

              ],
            ),
          ),
        ),
      ),
    );
  }
}



