import 'package:flutter/material.dart';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/response_model/fetchNewCarResponse.dart';
import 'package:ridealike/widgets/map_marker.dart';
import 'package:ridealike/constants/text_styles.dart';
import 'package:ridealike/widgets/rating_stars.dart';

class SwapCarListClusterNonSearch extends StatelessWidget {
  final Stream<FetchNewCarResponse>? stream;
  // final Stream stream;
  final List<MapMarker> points;

  SwapCarListClusterNonSearch({required this.stream, required this.points});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FetchNewCarResponse>(
        stream: stream,
        builder: (context, snapshot) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: points.length,
              itemBuilder: (context, index){
                if(snapshot.hasData) {
                  return ListTile(
                    onTap: (){
                      Navigator.pushNamed(
                          context, '/create_profile_or_sign_in');
                    },
                    leading: snapshot.data!.cars![points[index].id].imageId == ""
                        ? AssetImage('images/car-placeholder.png') as Widget?
                        : Image.network('$storageServerUrl/${snapshot.data!.cars![points[index].id].imageId}',
                      width: 110,
                      height: 73,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      snapshot.data!.cars![points[index].id].title!,
                      style: titleClusterCarCardTextStyle,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          snapshot.data!.cars![points[index].id].year!,
                          style: subTitleClusterCarCardTextStyle,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        snapshot.data!.cars![points[index].id]!= null &&  snapshot.data!.cars![points[index].id].numberOfTrips != null&&
                            snapshot.data!.cars![points[index].id].numberOfTrips != '0'?
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
                            Text(
                                  snapshot.data!.cars![points[index].id].numberOfTrips!='1'?
                                    '${snapshot.data!.cars![points[index].id].numberOfTrips} trips':
                                  '${snapshot.data!.cars![points[index].id].numberOfTrips} trip',
                              style: subTitleClusterCarCardTextStyle,
                            ),
                          ],
                        ):Text(''),
                      ],
                    ),
                    // Text('Car year'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$' + snapshot.data!.cars![points[index].id].price!,
                          style: titleClusterCarCardTextStyle,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: snapshot.data!.cars![points[index].id].rating != 0
                              ? List.generate(5, (indexIcon) {
                            return Icon(
                              Icons.star,
                              size: 13,
                              color: indexIcon < snapshot.data!.cars![points[index].id].rating!.round() ? Color(0xff5BC0EB).withOpacity(0.8) : Colors.grey,
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
                      ],),
                  );
                }
                return Container();
              });
        }
    );
  }
}