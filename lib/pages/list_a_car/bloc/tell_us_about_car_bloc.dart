import 'package:google_maps_flutter_platform_interface/src/types/location.dart' as location;
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:rxdart/rxdart.dart';

class SetAboutCarBloc extends Object with Validators implements BaseBloc{

  final _locationNotesController=BehaviorSubject<String>();
  final _neverBrandedOrSalvageTitleController=BehaviorSubject<bool>();
  final _vehicleDescriptionController=BehaviorSubject<String>();
  final _carDataController = BehaviorSubject<CreateCarResponse>();

  Function(String) get changedLocationNotes=>_locationNotesController.sink.add;
  Function(String) get changedVehicleDescription=>_vehicleDescriptionController.sink.add;
  Function(CreateCarResponse) get changedCarData=>_carDataController.sink.add;
  Function(bool) get changedNeverBrandedOrSalvageTitle=>_neverBrandedOrSalvageTitleController.sink.add;

  Stream<String> get locationNotes=> _locationNotesController.stream;
  Stream<String> get vehicleDescription=> _vehicleDescriptionController.stream;
  Stream<CreateCarResponse> get carData=> _carDataController.stream;
  Stream<bool> get neverBrandedOrSalvageTitle=> _neverBrandedOrSalvageTitleController.stream.transform(termsValidator);

  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;


  @override
  void dispose() {
    _locationNotesController.close();
    _neverBrandedOrSalvageTitleController.close();
    _vehicleDescriptionController.close();
    _carDataController.close();
    _progressIndicatorController.close();
  }

  void changeYear(DateTime val, CreateCarResponse data) {
    data.car!.about!.year =val.year.toString();
    data.car!.about!.year!.compareTo( data.car!.about!.year!);
    changedCarData.call(data);

  }

  setDescription(CreateCarResponse data, String value) {
    data.car!.about!.vehicleDescription=value;
    changedCarData.call(data);
  }

  void setLocation(location.LatLng latLong, CreateCarResponse data) {
    data.car!.about!.location!.latLng!.latitude = latLong.latitude;
    data.car!.about!.location!.latLng!.longitude = latLong.longitude;
    changedCarData.call(data);

  }

  void setUserLocation(LocationData value) {
    if (value != null){
      CreateCarResponse createCarResponse = _carDataController.stream.value;
      createCarResponse.car!.about!.location!.latLng!.latitude = value.latitude!;
      createCarResponse.car!.about!.location!.latLng!.longitude = value.longitude!;
      changedCarData.call(createCarResponse);

    }
  }
  checkButtonDisability( CreateCarResponse carData) {
    if (carData.car!.about!.make!= "" &&
        carData.car!.about!.model!= "" &&
        carData.car!.about!.carBodyTrim!= "" &&
        carData.car!.about!.style!= "" &&
        carData.car!.about!.year!="" && carData.car!.about!.carType!="" && carData.car!.about!.carOwnedBy!="" && carData.car!.about!.carOwnedBy!='CarOwnedByUndefined' &&
        carData.car!.about!.neverBrandedOrSalvageTitle!) {

      return false;
    } else {
      return true;

    }

  }
}