import 'dart:convert' show json;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/swap_car_map_bloc.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:shimmer/shimmer.dart';
class SwapGuest extends StatefulWidget {
  @override
  _SwapGuestState createState() => _SwapGuestState();
}

class _SwapGuestState extends State<SwapGuest> {
  List _newCarData = [];
  bool _isDataAvailable = false;
  bool _mapClick = false;

  final swapBloc = SwapCarMapBloc();

  @override
  Widget build(BuildContext context) {
    return
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _isDataAvailable
              ? Padding(
                padding: const EdgeInsets.only(left:12.0),
                child: Text(
            'Vehicles Available For Swap',
            style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
              )
              : Container(),
          SizedBox(height: 15),
          _isDataAvailable
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: false,
                    itemCount: _newCarData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: ()  {
                          Navigator.of(context)
                              .pushNamed('/create_profile_or_sign_in');
                        },
                        child: Container(

                          width: MediaQuery.of(context).size.width ,
                          height: 260,
                          child: Column(
                            children: <Widget>[
                              /*ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image(
                                  height: 200,
                                  width:
                                  MediaQuery.of(context).size.width * .90,
                                  image: _newCarData[index]['image_id'] == ""
                                      ? AssetImage('images/car-placeholder.png')
                                      : NetworkImage(
                                      '$storageServerUrl/${_newCarData[index]['image_id']}'),
                                  fit: BoxFit.cover,
                                ),
                              ),*/
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: MediaQuery.of(context).size.width * .93,
                                  imageUrl: "$storageServerUrl/${_newCarData[index]['image_id']}",
                                  placeholder: (context, url) => SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 220,
                          width: MediaQuery.of(context).size.width,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12.0, right: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: MediaQuery.of(context).size.width / 3,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 14,
                              width: MediaQuery.of(context).size.width / 2,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16.0, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 14,
                              width: MediaQuery.of(context).size.width / 2,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                                  errorWidget: (context, url, error) => Image.asset('images/car-placeholder.png', fit: BoxFit.cover,),
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left:12.0,right: 12),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _newCarData[index]['title'] != ' '
                                              ? _newCarData[index]['title']
                                              : 'Car title',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              _newCarData[index]['year'] != ''
                                                  ? _newCarData[index]['year']
                                                  : '2020',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'Urbanist',
                                                color: Color(0xff353B50),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            _newCarData[index]!=null
                                                &&  _newCarData[index]['number_of_trips']!=null &&
                                                _newCarData[index]['number_of_trips']!='0'?
                                            Row(
                                              children: [
                                                Container(
                                                  width: 2,
                                                  height: 2,
                                                  decoration: new BoxDecoration(
                                                    color: Color(0xff353B50),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                _newCarData[index]!=null
                                                    &&  _newCarData[index]['number_of_trips']!=null &&
                                                    _newCarData[index]['number_of_trips']!='0'?
                                                Text(
                                                  _newCarData[index]['number_of_trips']!='1'?
                                                  '${ _newCarData[index]['number_of_trips']} trips':'${ _newCarData[index]['number_of_trips']} trip',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal,
                                                    fontFamily: 'Urbanist',
                                                    color: Color(0xff353B50),
                                                  ),
                                                ):Text(''),
                                              ],
                                            ):Container(),

                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '\$ ' + _newCarData[index]['price'],
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children:   _newCarData[index]['rating'] != 0
                                              ? List.generate(5, (indexIcon) {
                                            return Icon(
                                              Icons.star,
                                              size: 13,
                                              color: indexIcon < _newCarData[index]['rating'].round() ? Color(0xff5BC0EB).withOpacity(0.8) : Colors.grey,
                                            );
                                          })
                                              : List.generate(5, (index) {
                                            return Icon(
                                              Icons.star,
                                              size: 0,
                                              color: Colors.white,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
            ),
          ),
                    SizedBox(height: MediaQuery.of(context).size.height*.15,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(16.0))),
                        backgroundColor: Color(0xff5BC0EB),

                      ),

                      child: SizedBox(
                        width: SizeConfig.deviceFontSize! * 63,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'MAP',
                              style: TextStyle(
                                color: Color(0xffFFFFFF),
                                letterSpacing: 0.4,
                                fontSize: 14,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            SizedBox(
                                width: 10
                            ),
                            Image.asset('icons/map.png'),
                          ],
                        ),
                      ),
                       onPressed:
                          () async {
                        // TODO map click issue
                        if (!_mapClick) {
                          _mapClick = true;
                          var _newCarData = await swapBloc.callFetchNewSwapCars();
                          Navigator.pushNamed(context, '/swap_car_map',
                              arguments: _newCarData).then((value) => _mapClick = false);
                        }
                      },

                    )
                  ],
                ),
              )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(strokeWidth: 2.5)
              ],
            ),
          ),


        ],
      );
  }



  callFetchSwapCars() async {
    var res = await fetchSwapCarData();
    setState(() {
      _newCarData = json.decode(res.body!)['cars'];
      _isDataAvailable = true;
    });
  }

  Future<http.Response> fetchSwapCarData() async {
    final response = await http.post(
        Uri.parse(getNewSwapCarsList));
        // getNewSwapCarsList as Uri);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    callFetchSwapCars();
  }
}
