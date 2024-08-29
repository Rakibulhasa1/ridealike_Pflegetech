import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/profile/response_service/faq_profile_response.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/sized_text.dart';


int i = 0;

bool selected = false;

Future<Resp> getAllFaqQuestions() async {
  var newCarCompleter = Completer<Resp>();
  callAPI(getAllUrl,json.encode(
      {}
  )).then((resp){
    newCarCompleter.complete(resp);
  });

  return newCarCompleter.future;


}

class FAQs extends StatefulWidget {
  @override
  _FAQsState createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool dataFetched = false;
  List<FAQ> rental = [];
  List<FAQ> rentout = [];
  List<FAQ> swap = [];

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Rental',),
    Tab(text: 'Rent out'),
    Tab(text: 'Swap'),
    
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: tabs.length);
    getAllFaqQuestions().then((faqQuestions){
      if(faqQuestions!=null){
        FaqProfileResponse response=FaqProfileResponse.fromJson(json.decode(faqQuestions.body!));
        List<FAQ> list = response.fAQ!;

        for(FAQ f in list){
          if(f.fAQType == 'rental'){
            rental.add(f);
          }
          if(f.fAQType == 'rent_out'){
            rentout.add(f);
          }
          if(f.fAQType == 'swap'){
            swap.add(f);
          }
        }

        setState(() {
          dataFetched = true;
          rental = rental;
          rentout = rentout;
          swap = swap;
        });

      }
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffFFFFFF),
        appBar: AppBar(centerTitle: true,
          title: Text(
            'FAQs',
            style: TextStyle(
            color: Color(0xff371D32),
            fontSize: 16,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500),
          ),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0.0,
          bottom: TabBar(
            indicatorColor: Color(0xffFF8F62),
            labelColor: Color(0xffFF8F62),
            unselectedLabelColor: Color(0xff371D32),
            tabs: tabs,
            controller: _tabController,
          ),
        ),
        body: dataFetched?
        TabBarView(
          controller: _tabController,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Topic',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w500,
                              color: Color(0xff371D32),
                              fontSize: 18),
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Flexible(flex: 3, child: _listViewQuestions(rental)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _listViewQuestions(rentout),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _listViewQuestions(swap),
            ),
          ],
        ): Container());
  }

  Widget _listViewQuestions(List<FAQ> key) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: key.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              setState(() {
                i=index;
                print(i.toString());
                Navigator.pushNamed(
                  context, '/profile_question_details_tab',
                    arguments: key[index]

                );
              });
            },
            child:
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.maxFinite,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffF2F2F2),
                          borderRadius: BorderRadius.circular(8.0),
                          shape: BoxShape.rectangle
                        ),
                        height: 50,
                        child: Container(
                          margin: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedText(
                                deviceWidth: SizeConfig.deviceWidth!,
                                textWidthPercentage: 0.67,
                                text: key[index].question!,
                                fontFamily: 'Urbanist',
                                textColor: Color(0xff371D32),
                                fontSize: 16,
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: Color(0xffABABAB),
                                size: 18,
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
