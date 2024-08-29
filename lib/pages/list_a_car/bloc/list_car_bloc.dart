import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/fetch_list_car_banner.dart';
import 'package:rxdart/rxdart.dart';

class ListCarBannerBloc extends Object with Validators implements BaseBloc{

  final _loggedInController=BehaviorSubject<bool>();
  final _bannerController=BehaviorSubject<List>();

  final storage = new FlutterSecureStorage();

  Function(bool) get changedLoggedInStatus =>_loggedInController.sink.add;
  Function(List) get changedBannerList=>_bannerController.sink.add;

  Stream<bool>get loggedInStatus=>_loggedInController.stream;

  fetchCarBannerList() async{
    String? userID = await storage.read(key: 'user_id');

    if(userID!=null){
      _loggedInController.sink.add(true);
      var res = await fetchListCarBanner();
      print('res${res.body}');
    }else{
      _loggedInController.sink.add(false);
    }  
  }

  @override
  void dispose() {
    _loggedInController.close();
    _bannerController.close();
  }

}