import 'package:flutter/material.dart';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/widgets/map_marker.dart';
import 'package:ridealike/constants/text_styles.dart';
import 'package:ridealike/widgets/rating_stars.dart';

class CarListClusterOnSearch extends StatelessWidget {

  final List<MapMarker> points;
  final List carData;
  final String? startDate, endDate;

  const CarListClusterOnSearch({required this.points, required this.carData, this.startDate, this.endDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: points.length,
          itemBuilder: (context, index){
            return Container(

              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                onTap: (){
                  Navigator.pushNamed(
                      context,
                      '/car_details',
                      arguments: {
                        "CarID": carData[points[index].id]['ID'],
                        "StartDate":startDate,
                        "EndDate": endDate
                      }
                  );
                },
                leading: carData[points[index].id]['ImageID'] == ""
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                                      'images/car-placeholder.png',
                                      width: 110,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                    )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                                      '$storageServerUrl/${carData[points[index].id]['ImageID']}',
                                      width: 110,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                    ),

                // leading: carData[points[index].id]['ImageID'] == ""
                //     ? AssetImage('images/car-placeholder.png')
                //     : Image.network('$storageServerUrl/${carData[points[index].id]['ImageID']}',
                //   width: 110,
                //   height: 73,
                //   fit: BoxFit.fill,
                // ),
                title: Text(
                  carData[points[index].id]['Title'],
                  style: titleClusterCarCardTextStyle,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      carData[points[index].id]['Year'],
                      style: subTitleClusterCarCardTextStyle,
                    ),
                    carData[points[index].id] != null &&  carData[points[index].id]['NumberOfTrips'] != null&&
                        carData[points[index].id]['NumberOfTrips']!= '0'?
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
                        SizedBox(width: 4,),
                        Text(carData[points[index].id]['NumberOfTrips']!='1'?
                               '${carData[points[index].id]['NumberOfTrips']} trips':   '${carData[points[index].id]['NumberOfTrips']} trip',
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
                      '\$' + carData[points[index].id]['Price'],
                      style: titleClusterCarCardTextStyle,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: carData[points[index].id]['Rating'] != 0
                          ? List.generate(5, (indexIcon) {
                        return Icon(
                          Icons.star,
                          size: 13,
                          color: indexIcon < carData[points[index].id]['Rating'].round() ? Color(0xff5BC0EB).withOpacity(0.8) : Colors.grey,
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
              ),
            );
          }),
    );
  }
}