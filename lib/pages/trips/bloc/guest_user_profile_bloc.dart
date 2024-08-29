import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/trips/request_service/guest_profile_request.dart';
import 'package:ridealike/pages/trips/response_model/guest_profile_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_verification_response.dart';
import 'package:ridealike/pages/trips/response_model/trips_get_car_by_ids_response.dart' ;
import 'package:rxdart/rxdart.dart';



class GuestUserProfileBloc implements BaseBloc {
  final guestUserProfileController = BehaviorSubject<ProfileResponse>();
  final guestProfileVerificationController = BehaviorSubject<ProfileVerificationResponseGuest>();
  final ratingReviewController = BehaviorSubject<String>();
  final replyRatingController = BehaviorSubject<String>();
  // final allTripsOfUserController = BehaviorSubject<TripAllUserStatusGroupResponse>();
  final allCarsOfUser = BehaviorSubject<GetCarsByCarIDsResponse>();

  var guestRatingReviews = null;

  Function(ProfileResponse) get changedProfileData => guestUserProfileController.sink.add;

  Function(ProfileVerificationResponseGuest) get changedProfileVerification => guestProfileVerificationController.sink.add;

  Function(String) get changedRatingReview => ratingReviewController.sink.add;
  Function(GetCarsByCarIDsResponse) get changedAllCars => allCarsOfUser.sink.add;

  Stream<ProfileResponse> get profileData => guestUserProfileController.stream;

  Stream<ProfileVerificationResponseGuest> get profileVerification => guestProfileVerificationController.stream;

  Stream<String> get ratingReview => ratingReviewController.stream;
  Stream<GetCarsByCarIDsResponse> get allCarsStream => allCarsOfUser.stream;


  fetchAllData(String userID) {
    fetchUserProfile(userID).then((value) {
      if (value != null) {
        var resp = ProfileResponse.fromJson(json.decode(value.body!));
        guestUserProfileController.sink.add(resp);

        fetchProfileVerification(resp.profile!.profileID).then((profileVerification) {
          if (profileVerification != null) {
            var verificationResp = ProfileVerificationResponseGuest.fromJson(json.decode(profileVerification.body!));
            guestProfileVerificationController.sink.add(verificationResp);
            fetchProfileRatingReviews(resp.profile!.profileID).then((ratingReview) {
              if(ratingReview!=null){
                guestRatingReviews = json.decode(ratingReview.body!)['Count'];
                // var ratingReviewResp=RatingReviewsResponse.fromJson(json.decode(ratingReview.body!));
                ratingReviewController.sink.add(guestRatingReviews);
                fetchUserCars(userID).then((fetchUserCarResp) {
                  if(fetchUserCarResp != null) {
                    GetCarsByCarIDsResponse? response = GetCarsByCarIDsResponse
                        .fromJson(json.decode(fetchUserCarResp.body!));
                    if (response != null) {
                      allCarsOfUser.sink.add(response);
                    }
                  }

                });

              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    guestUserProfileController.close();
    guestProfileVerificationController.close();
    ratingReviewController.close();
    allCarsOfUser.close();
  }
}
