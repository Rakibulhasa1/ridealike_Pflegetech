
bool isEmpty(int number) {
  if(number == null || number ==0){
    return true;
  } else{
    return false;
  }
}
bool isEmptyDouble(double number) {
  if(number == null || number ==0){
    return true;
  } else{
    return false;
  }
}
bool isEmptyBool(bool  offer) {
  if(offer == true){
    return true;
  } else{
    return false;
  }
}
bool isEmptyString(String string) {
  if(string == null || string.trim() =='' || string.endsWith('Undefined')){
    return true;
  } else{
    return false;
  }
}