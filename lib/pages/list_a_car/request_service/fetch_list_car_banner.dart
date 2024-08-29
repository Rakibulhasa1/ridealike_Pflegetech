import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchListCarBanner() async {

  var bannerCompleter=Completer<Resp>();

  callAPI(getListCarBannerUrl,json.encode(
      {}
      )).then((resp){
        bannerCompleter.complete(resp);

  });
return bannerCompleter.future;
}