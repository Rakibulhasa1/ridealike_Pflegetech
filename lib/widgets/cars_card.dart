import 'package:flutter/material.dart';

final List<String> imgList = [
  'https://source.unsplash.com/YApiWyp0lqo/1600x900',
  'https://source.unsplash.com/rz6uea4t8mQ/1600x900',
  'https://source.unsplash.com/e9zSM8orIfA/1600x900',
  'https://source.unsplash.com/aIbR-deTiWY/1600x900',
  'https://source.unsplash.com/esvWH-owWug/1600x900',
  'https://source.unsplash.com/iiiMcBYdhCU/1600x900'
];

class CarsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/car_details');
      },
      child: Container(
        height: 276,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: false,
          itemCount: imgList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(right: 16),
              width: 345,
              height: 276,
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      height: 200,
                      width: 345,
                      image: NetworkImage(imgList[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Lamborghini Aventador',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                '2018',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Urbanist',
                                  color: Color(0xff353B50),
                                ),
                              ),
                              Text('.'),
                              Text(
                                '1 trip',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Urbanist',
                                  color: Color(0xff353B50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "\$129/day",
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .copyWith(color: Color(0xff353B50)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 13,
                                color: Color(0xff7CB7B6),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class StarDisplay extends StatelessWidget {
  final int value;

  const StarDisplay({Key? key, this.value = 0})
      : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 12,
        );
      }),
    );
  }
}
