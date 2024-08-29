import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MapButtonBloc{
  // ignore: close_sinks
  static final _mapButtonController = BehaviorSubject<bool>();
  static StreamSink<bool> get mapButtonSink => _mapButtonController.sink;
  static Stream<bool> get mapButtonStream => _mapButtonController.stream;

}