class GuestInterface {
  void onDataLoadStarted(bool isStarted) {}

  void onDataLoadSuccess(double guestPrice) {}

  void onDataLoadFail( errorMessage) {}
  void onSubmitStart(bool isStarted){}
  void onSubmitSuccess(bool isSuccess){}
}
