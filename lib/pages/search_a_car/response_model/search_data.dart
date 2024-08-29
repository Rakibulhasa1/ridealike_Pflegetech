import 'package:ridealike/pages/search_a_car/response_model/make_response_model.dart';
import 'package:ridealike/pages/search_a_car/response_model/model_response.dart';

class SearchData {
  double? locationLat = 0.0;
  double? locationLon = 0.0;
  String? locationAddress = '';
  String? formattedLocationAddress = '';
  String locationAddressForShow = 'Select Location';
  DateTime? tripStartDate;
  double? tripStartTime;
  DateTime? tripEndDate;
  double? tripEndTime;
  List<String>? carType = [];
  List<CarMakes>? carMake = [];
  List<CarModels>? carModel = [];
  List<String>? greenFeature;
  bool? save;
  bool? superHost;
  bool? deliveryAvailable;
  bool? favourite;
  bool? isSuitableForPets;
  double? lat;
  double? long;

  double totalTripCostLowerRange = 0.00;
  double totalTripCostUpperRange = 1000.0;
  double? totalTripNumberLowerRange = 1.00;
  double? totalTripNumberUpperRange = 20.0;
  double? totalTripSeatsLowerRange = 2.00;
  double? totalTripSeatsUpperRange = 10.0;
  double? totalTripMileageLowerRange = 0.00;
  double? totalTripMileageUpperRange = 3000.0;
  String sortBy = 'None';
  String ecoSortBy = 'Hybrid';


  bool? read;

  SearchData(
      { this.locationLat,
        this.locationLon,
        this.locationAddress,
        this.formattedLocationAddress,
        this.tripStartDate,
        this.tripStartTime,
        this.tripEndDate,
        this.tripEndTime,
        this.carType,
        this.carMake,
        this.carModel,
        this.greenFeature,
        required this.totalTripCostLowerRange,this.totalTripMileageLowerRange,this.totalTripMileageUpperRange,
        required this.totalTripCostUpperRange,
        required this.sortBy,this.isSuitableForPets,this.totalTripSeatsLowerRange,this.totalTripSeatsUpperRange,
        this.locationAddressForShow = 'Current Location', this.superHost,this.deliveryAvailable,this.favourite,
        this.save = false, this.totalTripNumberLowerRange,  this.totalTripNumberUpperRange});

}
