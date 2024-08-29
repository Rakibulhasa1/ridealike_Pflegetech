class StatusOfCarList {
  String carAbout ;
  String imagesAndDocuments ;
  String features ;
  String preference ;
  String availability ;
  String pricing ;
  int selection;
  int purpose;

  StatusOfCarList(this.carAbout, this.imagesAndDocuments, this.features,
      this.preference, this.availability, this.pricing, this.selection, this.purpose);

  void maintainSelection() {
    if(carAbout == StatusValue.notAccessible){
      carAbout = StatusValue.turn;
      selection = 1;
    }else if(imagesAndDocuments == StatusValue.notAccessible){
      imagesAndDocuments = StatusValue.turn;
      selection = 2;
    }else if(features == StatusValue.notAccessible){
      features = StatusValue.turn;
      selection = 3;
    }else if(preference == StatusValue.notAccessible){
      preference = StatusValue.turn;
      selection = 4;
    }else if(availability == StatusValue.notAccessible){
      availability = StatusValue.turn;
      selection = 5;
    }else if(pricing == StatusValue.notAccessible){
      pricing = StatusValue.turn;
      selection = 6;
    }else{
      selection=7;
    }

  }

}
class StatusValue{
  static final completed="Completed";
  static final turn ='Turn';
  static final notAccessible ='NotAccessible';

}