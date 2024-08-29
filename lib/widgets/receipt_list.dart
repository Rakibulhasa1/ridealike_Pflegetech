import 'package:flutter/material.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';

import '../utils/app_events/app_events_utils.dart';

class ReceiptListPage extends StatelessWidget {
  const ReceiptListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Receipt List"});
    Trips tripArgument = ModalRoute.of(context)!.settings.arguments as Trips;
    print(tripArgument.noOfTripRequest);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Receipts"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: int.tryParse(tripArgument.noOfTripRequest!)!+1,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ButtonTheme(
                height: 60,
                minWidth: MediaQuery.of(context).size.width,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Color(0xffFF8F68),
                  ),
                  onPressed: () {
                    tripArgument.receiptIndex =index;
                    Navigator.pushNamed(context, "/latest_receipt",
                        arguments: tripArgument);
                  },

                  child: Text(
                    index==0?"Initial receipt":int.tryParse(tripArgument.noOfTripRequest!)==index? "Latest Receipt":"Adjustment $index",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Urbanist',
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
