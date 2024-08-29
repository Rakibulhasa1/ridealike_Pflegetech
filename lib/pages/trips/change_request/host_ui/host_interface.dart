class HostInterface {
  void onDataLoadSuccess(res) {}
  void onDataLoadError() {}
  void onDataLoading(bool load) {}
  void onAcceptRequest(bool isAccepted){}
  void onCancelRequest(bool isRejected){}
  void onGetChangeRequest(){}
}
