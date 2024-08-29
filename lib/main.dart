import 'dart:async';
import 'dart:convert' show json, jsonEncode;
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:http/http.dart' as http;
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/book_a_car/trip_booked.dart' as _tripBooked;
import 'package:ridealike/pages/car_details_non_search.dart'
    as _carDetailsNonSearch;
import 'package:ridealike/pages/car_reviews.dart' as _carReviewsPage;

//constants
import 'package:ridealike/pages/common/constant_url.dart';

//constants
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/create_a_profile/response_model/add_identity_image_response.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/create_a_profile/ui/terms_and_conditions_ui.dart'
    as _termsAndConditionsUI;
import 'package:ridealike/pages/create_a_profile/ui/verify_phone_number_ui.dart'
    as _verifyPhoneNumberUi;
import 'package:ridealike/pages/create_a_profile/ui/verify_security_code_ui.dart'
    as _verifySecurityCodeUi;
import 'package:ridealike/pages/dashboard/cancelled_trips.dart'
    as _dashboardTripsCancelledDetails;
import 'package:ridealike/pages/dashboard/dashboard.dart' as _dashboardTab;
import 'package:ridealike/pages/dashboard/dashboard_past_rent_out.dart'
    as _dashboardTripsRentOut;
import 'package:ridealike/pages/dashboard/dashboard_past_trips.dart'
    as _dashboardPastTrips;
import 'package:ridealike/pages/dashboard/dashboard_tabs_view/dashboard_reviews_tab.dart'
    as _dashboardReviewsTabPage;

//Dashboard //
import 'package:ridealike/pages/dashboard/dashboard_tabs_view/dashboard_tab.dart'
    as _dashboardTabViewPage;
import 'package:ridealike/pages/dashboard/dashboard_tabs_view/deactivate_your_listing_tab.dart'
    as _dashboardDeactivateListingTabPage;
import 'package:ridealike/pages/dashboard/dashboard_tabs_view/edit_your_listing_tab.dart'
    as _dashboardEditYourListingTabPage;
import 'package:ridealike/pages/dashboard/dashboard_tabs_view/manage_calendar_tab.dart'
    as _dashboardCalendarTabPage;
import 'package:ridealike/pages/dashboard/latest_receipt.dart'
    as _latestReceiptPage;
import 'package:ridealike/pages/dashboard/past_trips.dart' as _pastTripsPage;
import 'package:ridealike/pages/dashboard/receipt.dart' as _receiptPage;
import 'package:ridealike/pages/dashboard/receipt_swap.dart'
    as _receiptSwapPage;

// Dashboard
import 'package:ridealike/pages/dashboard/transactions.dart'
    as _transactionPage;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/discover/ui/discover_car_map.dart'
    as _discoverCarMap;
import 'package:ridealike/pages/discover/ui/discover_rent_ui.dart'
    as _discoverRentUi;
import 'package:ridealike/pages/discover/ui/swap_car_map.dart' as _swapCarMap;
import 'package:ridealike/pages/forgot_password.dart' as _forgotPasswordPage;
import 'package:ridealike/pages/list_a_car/ui/add_a_feature_ui.dart'
    as _addFeatureUi;
import 'package:ridealike/pages/list_a_car/ui/add_photos_to_your_listing_ui.dart'
    as _addPhotosToCarListUi;
import 'package:ridealike/pages/list_a_car/ui/car_body_trim_ui.dart'
    as _carBodyTrimUi;
import 'package:ridealike/pages/list_a_car/ui/car_make_ui.dart' as _carMakeUi;
import 'package:ridealike/pages/list_a_car/ui/car_model_ui.dart' as _carModelUi;
import 'package:ridealike/pages/list_a_car/ui/car_style_ui.dart' as _carStyleUi;
import 'package:ridealike/pages/list_a_car/ui/car_type_ui.dart' as _carTypeUi;
import 'package:ridealike/pages/list_a_car/ui/edit_a_feature_ui.dart'
    as _editFeaturesUi;

//payment Method//
import 'package:ridealike/pages/list_a_car/ui/how_would_you_like_to_be_paid_out_ui.dart'
    as _paymentMethodUi;
import 'package:ridealike/pages/list_a_car/ui/license_province_ui.dart'
    as _licenseProvincePageUi;
import 'package:ridealike/pages/list_a_car/ui/price_your_car_ui.dart'
    as _priceYourCarUi;
import 'pages/dashboard/dashboard_edit_pricing.dart' as _dashboardEditPricing;
import 'package:ridealike/pages/list_a_car/ui/set_up_bank_transfer_ui.dart'
    as _bankTransferUi;
import 'package:ridealike/pages/list_a_car/ui/set_up_interac_ui.dart'
    as _interacPaymentUi;
import 'package:ridealike/pages/list_a_car/ui/set_up_paypal_ui.dart'
    as _paypalSetUpUi;
import 'package:ridealike/pages/list_a_car/ui/set_your_car_availability_ui.dart'
    as _setCarAvailabilityUi;
import 'package:ridealike/pages/list_a_car/ui/set_your_car_rules_ui.dart'
    as _setYourRulesUi;
import 'package:ridealike/pages/list_a_car/ui/tell_us_about_your_car_ui.dart'
    as _tellUsAboutCarUi;
import 'package:ridealike/pages/list_a_car/ui/what_features_do_you_have_ui.dart'
    as _CarFeaturesUi;

//List a car//
import 'package:ridealike/pages/list_a_car/ui/what_will_happen_next_ui.dart'
    as _whatHappensNextUiPage;

//user login & social Login//
import 'package:ridealike/pages/log_in/ui/login_ui.dart' as _loginUi;
import 'package:ridealike/pages/messages/events/inboxEvent.dart';
import 'package:ridealike/pages/messages/events/messageEvent.dart';

//messages//
import 'package:ridealike/pages/messages/messages_chat_room_tab.dart'
    as _messagesChatRoomTabPage;
import 'package:ridealike/pages/messages/models/message.dart';
import 'package:ridealike/pages/messages/models/swap.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart'
    as _threadListView;
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/pages/messages/utils/socket_client.dart';
import 'package:ridealike/pages/profile/notification.dart'
    as _profileNotificationPage;
import 'package:ridealike/pages/profile/notificatoins_details.dart'
    as _profileNotificationsDetails;
import 'package:ridealike/pages/profile/profile_tabs_view/about_rideAlike_tab.dart'
    as _aboutRideAlikeTab;
import 'package:ridealike/pages/profile/profile_tabs_view/about_you_tab.dart'
    as _aboutYouTab;
import 'package:ridealike/pages/profile/profile_tabs_view/change_about_me_tab.dart'
    as _profileChangeAboutMeTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/change_email_tab.dart'
    as _profileChangeEmailTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/change_password_tab.dart'
    as _profileChangePasswordTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/change_phone_tab.dart'
    as _profileChangePhoneTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/edit_profile_tab.dart'
    as _profileEditTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/frequently_asked_questions_tab.dart'
    as _profileFAQsTAbPAge;
import 'package:ridealike/pages/profile/profile_tabs_view/give_us_feedback_tab.dart'
    as _profileFeedbackTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/notifications_settings_tab.dart'
    as _profileNotificationsSettingsTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/payment_method_tab.dart'
    as _profilePaymentMethodTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/payout_method_tab.dart'
    as _profilePayoutMethodTabPage;

//profile//
import 'package:ridealike/pages/profile/profile_tabs_view/quations_details_profile_tab.dart'
    as _profileFAQsQuestionDetailsTabPage;
import 'package:ridealike/pages/profile/profile_tabs_view/support_tab.dart'
    as _supportTab;
import 'package:ridealike/pages/profile/response_service/unread_notification_response.dart';
import 'package:ridealike/pages/profile/submit_claim.dart' as _submitClaim;
import 'package:ridealike/pages/search_a_car/search_car_green_feature.dart'
    as _searchGreenFeaturePage;
import 'package:ridealike/pages/search_a_car/search_car_make.dart'
    as _searchCarMakePage;
import 'package:ridealike/pages/search_a_car/search_car_map.dart'
    as _searchCarMapPage;
import 'package:ridealike/pages/search_a_car/search_car_model.dart'
    as _searchCarModelPage;
import 'package:ridealike/pages/search_a_car/search_car_sort_tab.dart'
    as _searchCarSortTabPage;
//Search car //

import 'package:ridealike/pages/search_a_car/search_car_tab.dart'
    as _searchCarTabPage;
import 'package:ridealike/pages/search_a_car/search_car_trip_duration.dart'
    as _searchCarTripDurationPage;
import 'package:ridealike/pages/search_a_car/search_car_type.dart'
    as _searchCarTypePage;
import 'package:ridealike/pages/search_a_car/search_location.dart'
    as _searchCarLocation;
import 'package:ridealike/pages/swap/agree_with_swap_terms.dart'
    as _agreeWithSwapTerms;
import 'package:ridealike/pages/swap/chance_to_swap.dart' as _chanceToSwap;
import 'package:ridealike/pages/swap/swap_arrange_terms.dart'
    as _swapArrangeTerms;
import 'package:ridealike/pages/swap/swap_car_details.dart' as _swapCarDetails;
import 'package:ridealike/pages/swap/swap_duration.dart' as _swapDuration;
import 'package:ridealike/pages/swap/swap_insurance.dart' as _swapInsurance;
import 'package:ridealike/pages/swap/swap_location.dart' as _swapLocation;
import 'package:ridealike/pages/swap/swap_preferences.dart' as _swapPreferences;

// Swap preferences
import 'package:ridealike/pages/swap/swap_preferences_tab.dart'
    as _swapPreferencesTab;
import 'package:ridealike/pages/swap/swap_trip_booked.dart' as _swapTripBooked;
import 'package:ridealike/pages/terms_and_conditions.dart'
    as _termsAndConditions;
import 'package:ridealike/pages/terms_conditions_policy/code_of_conduct.dart'
    as CodeOfContuct;
import 'package:ridealike/pages/terms_conditions_policy/privacy_policy.dart'
    as PrivacyAndPolicy;

//Terms & conditions & privacy Policy//
import 'package:ridealike/pages/terms_conditions_policy/terms_conditions.dart'
    as TermsCondition;
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/trips.dart' as _tripsPage;

//user create profile//
import 'package:ridealike/pages/trips/ui/common_inspection_ui.dart'
    as _commonInspectionUi;
import 'package:ridealike/pages/trips/ui/exterior_inspection.dart'
    as _exteriorInspectionUIPage;
import 'package:ridealike/pages/trips/ui/fuelgauge_inspection.dart'
    as _FuelGaugeUIPage;
import 'package:ridealike/pages/trips/ui/guest_end_trip_details_ui.dart'
    as _guestendTripDetails;
import 'package:ridealike/pages/trips/ui/guest_end_trip_inspection_ui.dart'
    as _endTripUi;
import 'package:ridealike/pages/trips/ui/guest_end_trip_inspection_ui.dart';
import 'package:ridealike/pages/trips/ui/guest_start_inspection_ui.dart'
    as _guestStartInspectionInfo;
import 'package:ridealike/pages/trips/ui/guest_start_trip_details.dart'
    as _guestStartTripDetails;
import 'package:ridealike/pages/trips/ui/host_end_inspection_ui.dart'
    as _HostEndInspectionUi;
import 'package:ridealike/pages/trips/ui/host_end_trip_details_ui.dart'
    as _hostendTripDetails;
import 'package:ridealike/pages/trips/ui/host_start_trip_details.dart'
    as _hostStartTripDetails;
import 'package:ridealike/pages/trips/ui/inspection_ui.dart'
    as _tripsRentedOutInspectionUi;
import 'package:ridealike/pages/trips/ui/interior_inspection.dart'
    as _interiorInspectionUIPage;
import 'package:ridealike/pages/trips/ui/odometer_inspection.dart'
    as _OdometerInspectionUIPage;
import 'package:ridealike/pages/trips/ui/reimbursement_modal_ui.dart'
    as _reimbursement;
import 'package:ridealike/pages/trips/ui/rentout_guest_end_trip_details.dart'
    as _rentoutGuestEndTripDetails;
import 'package:ridealike/pages/trips/ui/rentout_guest_start_trip_details.dart'
    as _rentoutGuestStartTripDetailsUi;
import 'package:ridealike/pages/trips/ui/rentout_host_end_trip_details.dart'
    as _rentoutHostEndTripDetails;
import 'package:ridealike/pages/trips/ui/rentout_host_start_trip_details.dart'
    as _rentoutHostStartTripDetailsUi;
import 'package:ridealike/pages/trips/ui/start_trip_ui.dart' as _startTripUi;
import 'package:ridealike/pages/trips/ui/swap_inspection_ui.dart'
    as _swapTripInspectionUi;
import 'package:ridealike/pages/trips/ui/trip_cancelled.dart'
    as _tripCancelledPage;

//trips//
import 'package:ridealike/pages/trips/ui/trips_cancelled_details.dart'
    as _tripsCancelledDetailsPage;
import 'package:ridealike/pages/trips/ui/trips_guest_profile.dart'
    as _tripsGuestProfileUi;
import 'package:ridealike/pages/trips/ui/trips_rental_details_ui.dart'
    as _tripRentalDetailsUi;
import 'package:ridealike/pages/trips/ui/trips_rented_out_details_ui.dart'
    as _tripsRentedOutUi;

//trips UI//
import 'package:ridealike/pages/trips/ui/trips_view_ui.dart' as _tripsViewUI;
import 'package:ridealike/pages/trips/ui/vehicle_ownership_ui.dart'
    as _vehicleOwnerShipUI;
import 'package:ridealike/pages/user_reviews.dart' as _userReviewsPage;
import 'package:ridealike/pages/version_alert.dart';
import 'package:ridealike/theme.dart';
import 'package:ridealike/utils/MyRouteObserver.dart';
import 'package:ridealike/utils/app_events/mixpanel_util.dart';

//profile Status utils
import 'package:ridealike/utils/profile_status.dart';

//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/map_button.dart';

//EventBus eventBus = EventBus();
//bool socketOn = false;
import 'package:ridealike/widgets/messages_help_modal.dart'
    as MessagesHelpModal;

//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';
import 'package:ridealike/widgets/receipt_list.dart' as _receiptListPage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import './pages/car_details.dart' as _carDetailsPage;

//import './pages/verification_in_progress.dart' as _verificationInProgressPage;
import './pages/create_profile.dart' as _createProfilePage;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_about_your_vehicle.dart'
    as _editDashboardAboutYourVehicle;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_add_a_feature.dart'
    as _editDashboardAddAFeature;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_car_body_trim.dart'
    as _editDashboardCarBodyTrim;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_car_make.dart'
    as _editDashboardCarMake;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_car_model.dart'
    as _editDashboardCarModel;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_car_style.dart'
    as _editDashboardCarStyle;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_car_type.dart'
    as _editDashboardCarType;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_edit_a_feature.dart'
    as _editDashboardEditAFeature;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_license_province.dart'
    as _editDashboardLicenseProvince;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_photos_and_documents.dart'
    as _editDashboardPhotosAndDocuments;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_vehicle_availability.dart'
    as _editDashboardVehicleAvailability;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_vehicle_features.dart'
    as _editDashboardVehicleFeatures;

// Edit dashboard vehicle listing//
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_vehicle_preferences.dart'
    as _editDashboardVehiclePreferences;
import './pages/dashboard/edit_dashboard_vehicle_listing/edit_dashboard_vehicle_pricing.dart'
    as _editDashboardVehiclePricing;
// Edit vehicle listing//

// import './pages/google_map.dart' as _googleMapPage;
import './pages/insurance_policy.dart' as _insurancePolicy;
import './pages/intro/intro_page.dart';
import './pages/license_province.dart' as _licenseProvincePage;
import './pages/listing_completed.dart' as _listingCompletedPage;
import './pages/manage_your_calendar.dart' as _manageYourCalendar;

// import './pages/pickup_and_return_location.dart' as _pickupAndReturnLocationPage;
import './pages/review_your_listing.dart' as _reviewListingPage;
import './pages/support.dart' as _supportPage;
import './pages/trips/inspection_completed.dart' as _inspectionCompletedPage;
import './pages/user_profile.dart' as _userProfile;
import './pages/verify_email.dart' as _verifyEmailPage;
import './pages/verify_identity.dart' as _verifyIdentityPage;
import './pages/verify_your_car.dart' as _verifyCarPage;
import './pages/what_type_of_listing.dart' as _listingTypePage;
import './tabs/create_profile_or_sign_in.dart' as _createProfileOrSignInTab;
import './pages/create_a_profile/ui/create_profile_with_social_view.dart'
    as _createProfileWithSocialView;
import './tabs/create_profile_or_sign_in_view.dart'
    as _createProfileOrSignInViewTab;
import './tabs/discover.dart' as _discoverTab;
import './tabs/list_your_car.dart' as _listYourCarTab;
import 'pages/create_a_profile/ui/verification_in_progress.dart'
    as _verificationInProgressPage;

// Discover-Rent & Swap//
import 'pages/discover/ui/discover_swap.dart' as _discoverSwapPage;
import 'pages/discover/ui/discover_tab.dart' as _discoverTabRoute;
import 'pages/profile/profile_set_up_bank_transfer.dart'
    as _profileBankTransfer;
import 'pages/profile/profile_tabs_view/introduce_yourself.dart'
    as _introduceYourselfPage;
import 'pages/profile/profile_tabs_view/profile.dart' as _profilePage;
import 'pages/profile/profile_view.dart' as _profileView;
import 'pages/trips/host_trip_started.dart' as _hosttripStartedPage;
import 'pages/trips/start_trip.dart' as _startTripPage;
import 'pages/trips/trip_ended.dart' as _tripEndedPage;
import 'pages/trips/trip_started.dart' as _tripStartedPage;
import 'utils/app_events/app_events_utils.dart';
import 'widgets/calendar_picker.dart' as _calendarPicker;

//  Future<void> updateNotificationCount() async{
//   String userID = await FlutterSecureStorage().read(key: 'user_id');
//
//   if (userID != null) {
//     var unreadResponse = await fetchUnreadNotifications(userID);
//
//     unreadNotification =
//         UnreadNotificationResponse.fromJson(json.decode(unreadResponse.body!));
//     if (unreadNotification != null &&
//         unreadNotification.totalCount != null &&
//         unreadNotification.totalCount != '0') {
//       int count = int.tryParse(unreadNotification.totalCount);
//       notificationCount.value = count;
//       print('something from cechk');
//
//     }
//     print('unread${unreadNotification.totalCount}');
//   }
// }

void main() async {
  Timer.periodic(Duration(seconds: 5), (Timer t) {
    SocketClient.check();
    // updateNotificationCount();
  });
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterUxcam
        .optIntoSchematicRecordings(); // Confirm that you have user permission for screen recording
    FlutterUxConfig config = FlutterUxConfig(
        userAppKey: uxcamKey, enableAutomaticScreenNameTagging: false);
    FlutterUxcam.startWithConfiguration(config);
    await Firebase.initializeApp();
    await AppEventsUtils.init();
    HttpOverrides.global = MyHttpOverrides();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(
      MaterialApp(
        navigatorObservers: <NavigatorObserver>[MyRouteObserver()],
        navigatorKey: NavigationService.navigationKey,
        color: Colors.white,
        debugShowCheckedModeBanner: false,
        title: 'RideAlike',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Color(0xffFF8F68),
            // secondary: Colors.white,
          ),
        ),
        home: FutureBuilder(
          future: checkFirstTime(),
          builder: (context, snapshot) {
            //to get device size configuration
            SizeConfig().init(context);
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return snapshot.data as Widget;
            } else {
              return Container(
                  height: SizeConfig.deviceHeight,
                  width: SizeConfig.deviceWidth,
                  color: Colors.white,
                  child: Center(child: Image.asset('icons/splash2.png')));
            }
          },
        ),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/signin_ui':
              return FromRightToLeft(
                builder: (_) => new _loginUi.LoginUi(),
                settings: settings,
              );
            case '/support':
              return new FromRightToLeft(
                builder: (_) => new _supportPage.Support(),
                settings: settings,
              );
            case '/support_tab':
              return new FromRightToLeft(
                builder: (_) => new _supportTab.SupportTab(),
                settings: settings,
              );
            case '/submit_claim':
              return new FromRightToLeft(
                builder: (_) => new _submitClaim.SubmitClaim(),
                settings: settings,
              );
            case '/about_rideAlike_tab':
              return new FromRightToLeft(
                builder: (_) => new _aboutRideAlikeTab.AboutRideAlikeTab(),
                settings: settings,
              );
            case '/about_you_tab':
              return new FromRightToLeft(
                builder: (_) => new _aboutYouTab.AboutYouTab(),
                settings: settings,
              );
//            case '/signin':
//              return new FromRightToLeft(
//                builder: (_) => new _loginPage.Login(),
//                settings: settings,
//              );
            case '/profile':
              return new FromRightToLeft(
                builder: (_) => new _profilePage.Profile(),
                settings: settings,
              );

            case '/introduce_yourself':
              return new FromRightToLeft(
                builder: (_) => new _introduceYourselfPage.IntroduceYourself(),
                settings: settings,
              );
            case '/verify_email':
              return new FromRightToLeft(
                builder: (_) => new _verifyEmailPage.VerifyEmail(),
                settings: settings,
              );
//            case '/verify_security_code':
//              return new FromRightToLeft(
//                builder: (_) =>
//                new _verifySecurityCodePage.VerifySecurityCode(),
//                settings: settings,
//              );
            case '/verification_in_progress':
              return new FromRightToLeft(
                builder: (_) =>
                    new _verificationInProgressPage.VerificationInProgress(),
                settings: settings,
              );
//              case '/verification_in_progress':
//              return new FromRightToLeft(
//                builder: (_) =>
//                new _verificationInProgressPage.VerificationInProgress(),
//                settings: settings,
//              );
            case '/create_profile':
              return new FromRightToLeft(
                builder: (_) => new _createProfilePage.CreateProfile(),
                settings: settings,
              );
            case '/list_your_car':
              return new FromRightToLeft(
                builder: (_) => new _listYourCarTab.ListYourCar(),
                settings: settings,
              );
            case '/car_details':
              return new FromRightToLeft(
                builder: (_) => new _carDetailsPage.CarDetails(),
                settings: settings,
              );
            case '/discover_swap':
              return new FromRightToLeft(
                builder: (_) => new _discoverSwapPage.DiscoverSwap(),
                settings: settings,
              );
            case '/trip_booked':
              return new FromRightToLeft(
                builder: (_) => new _tripBooked.TripBooked(),
                settings: settings,
              );
            case '/reimbursement':
              return new FromRightToLeft(
                builder: (_) => new _reimbursement.ReimbursementModalUi(),
                settings: settings,
              );
//            case '/discover_rent':
//              return new FromRightToLeft(
//                builder: (_) => new _discoverRentPage.DiscoverRent(),
//                settings: settings,
//              );
//             case '/discover_rent':
//               return new FromRightToLeft(
//                 builder: (_) => new _discoverRentUi.DiscoverRent(),
//                 settings: settings,
//               );
//            case '/verify_identity':
//              return new FromRightToLeft(
//                builder: (_) => new _verifyIdentityPage.VerifyIdentity(),
//                settings: settings,
//              );//
            case '/verify_identity_ui':
              return new FromRightToLeft(
                builder: (_) => new _verifyIdentityPage.VerifyIdentity(),
                settings: settings,
              );
            case '/manage_your_calendar':
              return new FromRightToLeft(
                builder: (_) => new _manageYourCalendar.ManageYourCalendar(),
                settings: settings,
              );

            case '/what_will_happen_next_ui':
              return new FromRightToLeft(
                builder: (_) => new _whatHappensNextUiPage.WhatHappensNextUi(),
                settings: settings,
              );
            case '/tell_us_about_your_car_ui':
              return new FromRightToLeft(
                builder: (_) => new _tellUsAboutCarUi.TellUsAboutYourCarUI(),
                settings: settings,
              );
            case '/car_type_ui':
              return new FromRightToLeft(
                builder: (_) => new _carTypeUi.CarTypeUi(),
                settings: settings,
              );
            case '/car_make_ui':
              return new FromRightToLeft(
                builder: (_) => new _carMakeUi.CarMakeUi(),
                settings: settings,
              );
            case '/car_model_ui':
              return new FromRightToLeft(
                builder: (_) => new _carModelUi.CarModelUi(),
                settings: settings,
              );

            case '/trip_cancelled':
              return new FromRightToLeft(
                  builder: (_) => new _tripCancelledPage.TripCancelled(),
                  settings: settings);

            case '/car_body_trim_ui':
              return new FromRightToLeft(
                builder: (_) => new _carBodyTrimUi.CarBodyTrimUi(),
                settings: settings,
              );

            case '/car_style_ui':
              return new FromRightToLeft(
                builder: (_) => new _carStyleUi.CarStyleUi(),
                settings: settings,
              );
            case '/license_province':
              return new FromRightToLeft(
                builder: (_) => new _licenseProvincePage.LicenseProvicne(),
                settings: settings,
              );
            case '/license_province_ui':
              return new FromRightToLeft(
                builder: (_) => new _licenseProvincePageUi.LicenseProvinceUi(),
                settings: settings,
              );

            case '/add_photos_to_your_listing_ui':
              return new FromRightToLeft(
                builder: (_) =>
                    new _addPhotosToCarListUi.AddPhotosToListingUi(),
                settings: settings,
              );
            case '/verify_your_car':
              return new FromRightToLeft(
                builder: (_) => new _verifyCarPage.VerifyCar(),
                settings: settings,
              );

            case '/what_features_do_you_have_ui':
              return new FromRightToLeft(
                builder: (_) => new _CarFeaturesUi.WhatFeaturesYouHaveUi(),
                settings: settings,
              );
            case '/messages_help':
              return new FromRightToLeft(
                builder: (_) => new MessagesHelpModal.MessagesHelpModal(),
                settings: settings,
              );

            case '/add_a_feature_ui':
              return new FromRightToLeft(
                builder: (_) => new _addFeatureUi.AddFeatureUi(),
                settings: settings,
              );

            case '/edit_a_feature_ui':
              return new FromRightToLeft(
                builder: (_) => new _editFeaturesUi.EditFeatureUi(),
                settings: settings,
              );

            case '/set_your_car_rules_ui':
              return new FromRightToLeft(
                builder: (_) => new _setYourRulesUi.SetCarRulesUi(),
                settings: settings,
              );
            case '/what_type_of_listing':
              return new FromRightToLeft(
                builder: (_) => new _listingTypePage.ListingType(),
                settings: settings,
              );
            // case '/pickup_and_return_location':
            //   return new FromRightToLeft(
            //     builder: (_) =>
            //     new _pickupAndReturnLocationPage.PickupAndReturnLocation(),
            //     settings: settings,
            //   );

            case '/set_your_car_availability_ui':
              return new FromRightToLeft(
                builder: (_) => new _setCarAvailabilityUi.CarAvailabilityUi(),
                settings: settings,
              );
            // case '/google_map':
            //   return new FromRightToLeft(
            //     builder: (_) => new _googleMapPage.GoogleMapExample(),
            //     settings: settings,
            //   );

            case '/dashboard_edit_pricing':
              return new FromRightToLeft(
                builder: (_) => new _dashboardEditPricing.DashBoardEditPricing(),
                settings: settings,
              );

            case '/price_your_car_ui':
              return new FromRightToLeft(
                builder: (_) => new _priceYourCarUi.PriceYourCarUi(),
                settings: settings,
              );

            case '/how_would_you_like_to_be_paid_out_ui':
              return new FromRightToLeft(
                builder: (_) => new _paymentMethodUi.PaymentMethodUi(),
                settings: settings,
              );

            case '/set_up_paypal_ui':
              return new FromRightToLeft(
                builder: (_) => new _paypalSetUpUi.PayPalSetupUi(),
                settings: settings,
              );

            case '/set_up_bank_transfer_ui':
              return new FromRightToLeft(
                builder: (_) => new _bankTransferUi.BankTransferUi(),
                settings: settings,
              );

            case '/set_up_interac_ui':
              return new FromRightToLeft(
                builder: (_) => new _interacPaymentUi.InteracSetupUi(),
                settings: settings,
              );
            case '/review_your_listing':
              return new FromRightToLeft(
                builder: (_) => new _reviewListingPage.ReviewListing(),
                settings: settings,
              );
            case '/listing_completed':
              return new FromRightToLeft(
                builder: (_) => new _listingCompletedPage.ListingCompleted(),
                settings: settings,
              );
            case '/profile_question_details_tab':
              return new FromRightToLeft(
                builder: (_) => new _profileFAQsQuestionDetailsTabPage
                    .FAQsQuestionsDetailsTab(),
                settings: settings,
              );
            case '/profile_faqs_tab':
              return new FromRightToLeft(
                builder: (_) => new _profileFAQsTAbPAge.FAQSTab(),
                settings: settings,
              );
            case '/profile_payment_method_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _profilePaymentMethodTabPage.PaymentMethodTab(),
                settings: settings,
              );
            case '/profile_payout_method_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _profilePayoutMethodTabPage.PayoutMethodTab(),
                settings: settings,
              );
            case '/profile_notifications_settings_tab':
              return new FromRightToLeft(
                builder: (_) => new _profileNotificationsSettingsTabPage
                    .NotificationsSettingsTab(),
                settings: settings,
              );
            case '/profile_feedback_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _profileFeedbackTabPage.ProfileFeedbackTab(),
                settings: settings,
              );
            case '/profile_edit_tab':
              return new FromRightToLeft(
                builder: (_) => new _profileEditTabPage.ProfileEditTab(),
                settings: settings,
              );
            case '/profile_change_email_tab':
              return new FromRightToLeft(
                builder: (_) => new _profileChangeEmailTabPage.ChangeEmailTab(),
                settings: settings,
              );
            case '/profile_change_phone_tab':
              return new FromRightToLeft(
                builder: (_) => new _profileChangePhoneTabPage.ChangePhoneTab(),
                settings: settings,
              );
            case '/profile_change_password_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _profileChangePasswordTabPage.ChangePasswordTab(),
                settings: settings,
              );
            case '/profile_change_about_me_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _profileChangeAboutMeTabPage.ChangeAboutMeTab(),
                settings: settings,
              );
            case '/profile_notifications':
              return new FromRightToLeft(
                builder: (_) => new _profileNotificationPage.Notification(),
                settings: settings,
              );
            case '/insurance_policy':
              return new FromRightToLeft(
                builder: (_) => new _insurancePolicy.InsurancePolicy(),
                settings: settings,
              );
            case '/user_profile':
              return new FromRightToLeft(
                builder: (_) => new _userProfile.UserProfile(),
                settings: settings,
              );
            case '/terms_condition':
              return new FromRightToLeft(
                builder: (_) => new TermsCondition.TermsAndConditions(),
                settings: settings,
              );
            case '/privacy_policy':
              return new FromRightToLeft(
                builder: (_) => new PrivacyAndPolicy.PrivacyPolicy(),
                settings: settings,
              );
            case '/code_conduct':
              return new FromRightToLeft(
                builder: (_) => new CodeOfContuct.CodeOfConduct(),
                settings: settings,
              );
            case '/dashboard_tab':
              return new FromRightToLeft(
                builder: (_) => new _dashboardTabViewPage.DashboardTabView(),
                settings: settings,
              );
            case '/dashboard_calendar_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _dashboardCalendarTabPage.DashboardManageCalendarTab(),
                settings: settings,
              );
            case '/edit_your_listing_tab':
              return new FromRightToLeft(
                builder: (_) => new _dashboardEditYourListingTabPage
                    .DashboardEditYorListingTab(),
                settings: settings,
              );
            case '/deactivate_your_listing_tab':
              return new FromRightToLeft(
                builder: (_) => new _dashboardDeactivateListingTabPage
                    .DashboardDeactivateListingTab(),
                settings: settings,
              );
            case '/search_car_tab':
              return new FromRightToLeft(
                builder: (_) => new _searchCarTabPage.SearchTab(),
                settings: settings,
              );
            case '/search_car_type':
              return new FromRightToLeft(
                builder: (_) => new _searchCarTypePage.SearchCarType(),
                settings: settings,
              );
            case '/search_car_make':
              return new FromRightToLeft(
                builder: (_) => new _searchCarMakePage.SearchCarMake(),
                settings: settings,
              );
            case '/exterior_inspection_ui':
              return new FromRightToLeft(
                builder: (_) =>
                    new _exteriorInspectionUIPage.ExteriorInspectionUI(),
                settings: settings,
              );
            case '/interior_inspection_ui':
              return new FromRightToLeft(
                builder: (_) =>
                    new _interiorInspectionUIPage.InteriorInspectionUI(),
                settings: settings,
              );
            case '/fuel_gauge_ui':
              return new FromRightToLeft(
                builder: (_) => new _FuelGaugeUIPage.FuelGaugeInspectionUI(),
                settings: settings,
              );
            case 'odometer_inspection_ui':
              return new FromRightToLeft(
                builder: (_) =>
                    new _OdometerInspectionUIPage.OdometerInspectionUI(),
                settings: settings,
              );
            case '/search_car_model':
              return new FromRightToLeft(
                builder: (_) => new _searchCarModelPage.SearchCarModel(),
                settings: settings,
              );
            case '/search_car_green_feature':
              return new FromRightToLeft(
                builder: (_) =>
                    new _searchGreenFeaturePage.SearchCarGreenFeature(),
                settings: settings,
              );
            case '/search_car_sort_tab':
              return new FromRightToLeft(
                builder: (_) => new _searchCarSortTabPage.SearchCarSortByTab(),
                settings: settings,
              );
            case '/search_car_location':
              return new FromRightToLeft(
                builder: (_) => new _searchCarLocation.SearchCarLocation(),
                settings: settings,
              );
            case '/search_car_trip_duration':
              return new FromRightToLeft(
                builder: (_) =>
                    new _searchCarTripDurationPage.SearchCarTripDuration(),
                settings: settings,
              );
            case '/search_car_map':
              return new FromRightToLeft(
                builder: (_) => new _searchCarMapPage.SearchCarMap(),
                settings: settings,
              );
            // case '/edit_vehicle_preferences':
            //   return new FromRightToLeft(
            //     builder: (_) =>
            //         new _editVehiclePreferences.EditVehiclePreferences(),
            //     settings: settings,
            //   );
            // case '/edit_vehicle_availability':
            //   return new FromRightToLeft(
            //     builder: (_) =>
            //         new _editVehicleAvailability.EditVehicleAvailability(),
            //     settings: settings,
            //   );
            // case '/edit_vehicle_pricing':
            //   return new FromRightToLeft(
            //     builder: (_) => new _editVehiclePricing.EditVehiclePricing(),
            //     settings: settings,
            //   );
            // case '/edit_vehicle_features':
            //   return new FromRightToLeft(
            //     builder: (_) => new _editVehicleFeatures.EditVehicleFeatures(),
            //     settings: settings,
            //   );
            // case '/edit_photos_and_documents':
            //   return new FromRightToLeft(
            //     builder: (_) =>
            //         new _editPhotosAndDocuments.EditPhotosAndDocuments(),
            //     settings: settings,
            //   );
            // case '/edit_about_your_vehicle':
            //   return new FromRightToLeft(
            //     builder: (_) => new _editAboutYourVehicle.EditAboutYourVehicle(),
            //     settings: settings,
            //   );
            // case '/edit_car_type':
            //   return new FromRightToLeft(
            //     builder: (_) => new __editCarType.EditCarType(),
            //     settings: settings,
            //   );
            // case '/edit_car_make':
            //   return new FromRightToLeft(
            //     builder: (_) => new __editCarMake.EditCarMake(),
            //     settings: settings,
            //   );
            // case '/edit_car_model':
            //   return new FromRightToLeft(
            //     builder: (_) => new __editCarModel.EditCarModel(),
            //     settings: settings,
            //   );
            // case '/edit_car_body_trim':
            //   return new FromRightToLeft(
            //     builder: (_) => new __editCarBodyTrim.EditCarBodyTrim(),
            //     settings: settings,
            //   );
            // case '/edit_car_style':
            //   return new FromRightToLeft(
            //     builder: (_) => new __editCarStyle.EditCarStyle(),
            //     settings: settings,
            //   );
            // case '/edit_license_province':
            //   return new FromRightToLeft(
            //     builder: (_) => new _editLicenseProvince.EditLicenseProvicne(),
            //     settings: settings,
            //   );
            // case '/edit_add_a_feature':
            //   return new FromRightToLeft(
            //     builder: (_) => new _editAddAFeature.EditAddFeature(),
            //     settings: settings,
            //   );
            // case '/edit_edit_a_feature':
            //   return new FromRightToLeft(
            //     builder: (_) => new _editEditAFeature.EditEditFeature(),
            //     settings: settings,
            //   );

            case '/edit_dashboard_vehicle_preferences':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardVehiclePreferences
                    .EditDashboardVehiclePreferences(),
                settings: settings,
              );
            case '/edit_dashboard_vehicle_availability':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardVehicleAvailability
                    .EditDashboardVehicleAvailability(),
                settings: settings,
              );
            case '/edit_dashboard_vehicle_pricing':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardVehiclePricing
                    .EditDashboardVehiclePricing(),
                settings: settings,
              );
            case '/edit_dashboard_vehicle_features':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardVehicleFeatures
                    .EditDashboardVehicleFeatures(),
                settings: settings,
              );
            case '/edit_dashboard_photos_and_documents':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardPhotosAndDocuments
                    .EditDashboardPhotosAndDocuments(),
                settings: settings,
              );
            case '/edit_dashboard_about_your_vehicle':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardAboutYourVehicle
                    .EditDashboardAboutYourVehicle(),
                settings: settings,
              );
            case '/edit_dashboard_car_type':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardCarType.EditDashboardCarType(),
                settings: settings,
              );
            case '/edit_dashboard_car_make':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardCarMake.EditDashboardCarMake(),
                settings: settings,
              );
            case '/edit_dashboard_car_model':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardCarModel.EditDashboardCarModel(),
                settings: settings,
              );
            case '/edit_dashboard_car_body_trim':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardCarBodyTrim.EditDashboardCarBodyTrim(),
                settings: settings,
              );
            case '/edit_dashboard_car_style':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardCarStyle.EditDashboardCarStyle(),
                settings: settings,
              );
            case '/edit_dashboard_license_province':
              return new FromRightToLeft(
                builder: (_) => new _editDashboardLicenseProvince
                    .EditDashboardLicenseProvicne(),
                settings: settings,
              );
            case '/edit_dashboard_add_a_feature':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardAddAFeature.EditDashboardAddFeature(),
                settings: settings,
              );
            case '/edit_dashboard_edit_a_feature':
              return new FromRightToLeft(
                builder: (_) =>
                    new _editDashboardEditAFeature.EditDashboardEditFeature(),
                settings: settings,
              );
            case '/discover_tab':
              return new FromRightToLeft(
                builder: (_) => new _discoverTabRoute.DiscoverTab(),
                settings: settings,
              );
            case '/trips_cancelled_details':
              return new FromRightToLeft(
                builder: (context) =>
                    new _tripsCancelledDetailsPage.TripsCancelledDetails(
                        ModalRoute.of(context)!.settings.arguments as Trips),
                settings: settings,
              );
            case '/trips_cancelled_details_notification':
              return new FromRightToLeft(
                builder: (context) =>
                    new _tripsCancelledDetailsPage.TripsCancelledDetails(
                        ((ModalRoute.of(context)!.settings.arguments)
                            as Map)['trip'],
                        backPressPop: ((ModalRoute.of(context)!
                            .settings
                            .arguments) as Map)['backPressPop']),
                settings: settings,
              );
            case '/dashboard_trips_cancelled_details':
              return new FromRightToLeft(
                builder: (context) => new _dashboardTripsCancelledDetails
                    .DashboardTripsCancelledDetails(
                    ModalRoute.of(context)!.settings.arguments as Trips),
                settings: settings,
              );
            case '/trips':
              return new FromRightToLeft(
                builder: (_) => new _tripsPage.TripsTab(),
                settings: settings,
              );
            case '/notifications_details':
              return new FromRightToLeft(
                builder: (_) =>
                    new _profileNotificationsDetails.NotificationsDetails(),
                settings: settings,
              );
            case '/messages_chat_room_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _messagesChatRoomTabPage.MessagesChatRoomTab(),
                settings: settings,
              );
            case '/transactions':
              return new FromRightToLeft(
                builder: (_) => new _transactionPage.Transactions(),
                settings: settings,
              );
            case '/dashboard_past_trips':
              return new FromRightToLeft(
                builder: (_) => new _pastTripsPage.DashboardPastTrips(),
                settings: settings,
              );
            case '/dashboard_reviews_tab':
              return new FromRightToLeft(
                builder: (_) =>
                    new _dashboardReviewsTabPage.DashboardReviewsTab(),
                settings: settings,
              );
            case '/login':
              return new FromRightToLeft(
                builder: (_) => new _loginUi.LoginUi(),
                settings: settings,
              );

            case '/trips_rent_out_details_ui':
              return new FromRightToLeft(
                  builder: (_) => new _tripsRentedOutUi.TripsRentOutDetails(),
                  settings: settings);
            case '/dashboard_past_trips_rent_out_details':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _dashboardTripsRentOut.DashboardTripsRentOutDetails(),
                  settings: settings);
            case '/trips_guest_profile_ui':
              return new FromRightToLeft(
                  builder: (_) => new _tripsGuestProfileUi.GuestProfileUi(),
                  settings: settings);
            case '/inspection_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _tripsRentedOutInspectionUi.InspectionUi(),
                  settings: settings);

            case '/host_end_inspection_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _HostEndInspectionUi.HostEndInspectionUi(),
                  settings: settings);
            case '/guest_start_inspection_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _guestStartInspectionInfo.GuestStartInspectionInfo(),
                  settings: settings);
            case '/guest_start_trip_details':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _guestStartTripDetails.GuestStartTripDetails(),
                  settings: settings);

            case '/host_start_trip_details':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _hostStartTripDetails.HostStartTripDetails(),
                  settings: settings);
            case '/swap_inspection_ui':
              return new FromRightToLeft(
                  builder: (_) => new _swapTripInspectionUi.SwapInspectionUi(),
                  settings: settings);
            case '/profile_set_up_bank_transfer':
              return new FromRightToLeft(
                  builder: (_) => new _profileBankTransfer.BankTransfer(),
                  settings: settings);
            case '/create_profile_with_social_view':
              return new FromRightToLeft(
                  builder: (_) => new _createProfileWithSocialView
                      .CreateProfileWithSocialView(),
                  settings: settings);

            case '/create_profile_or_sign_in':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _createProfileOrSignInTab.CreateProfileOrSignIn(),
                  settings: settings);

            case '/common_inspection_ui':
              return new FromRightToLeft(
                  builder: (_) => new _commonInspectionUi.CommonInspectionUI(),
                  settings: settings);

            case '/rentout_guest_start_trip_details':
              return new FromRightToLeft(
                  builder: (_) => new _rentoutGuestStartTripDetailsUi
                      .RentoutGuestStartTripDetails(),
                  settings: settings);

            case '/rentout_guest_end_trip_details':
              return new FromRightToLeft(
                  builder: (_) => new _rentoutGuestEndTripDetails
                      .RentoutGuestEndTripDetails(),
                  settings: settings);

            case '/rentout_host_end_trip_details':
              return new FromRightToLeft(
                  builder: (_) => new _rentoutHostEndTripDetails
                      .RentoutHostEndTripDetails(),
                  settings: settings);

            case '/rentout_host_start_trip_details':
              return new FromRightToLeft(
                  builder: (_) => new _rentoutHostStartTripDetailsUi
                      .RentoutHostStartTripDetails(),
                  settings: settings);

            case '/guest_end_trip_details':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _guestendTripDetails.GuestEndTripDetails(),
                  settings: settings);

            case '/host_end_trip_details':
              return new FromRightToLeft(
                  builder: (_) => new _hostendTripDetails.HostEndTripDetails(),
                  settings: settings);

            case '/trips_rental_details_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _tripRentalDetailsUi.TripsRentalDetailsUi(),
                  settings: settings);
            case '/dashboard_past_trips_details':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _dashboardPastTrips.DashboardTripsRentalDetails(),
                  settings: settings);
            case '/start_trip':
              return new FromRightToLeft(
                  builder: (_) => new _startTripPage.StartTrip(),
                  settings: settings);
            case '/start_trip_ui':
              return new FromRightToLeft(
                  builder: (_) => new _startTripUi.StartTripUi(),
                  settings: settings);
            case '/trip_started':
              return new FromRightToLeft(
                  builder: (_) => new _tripStartedPage.TripStarted(),
                  settings: settings);

            case '/host_trip_started':
              return new FromRightToLeft(
                  builder: (_) => new _hosttripStartedPage.HostTripStarted(),
                  settings: settings);

            case '/end_trip_ui':
              return new FromRightToLeft(
                  builder: (_) => new _endTripUi.EndTripUi(),
                  settings: settings);
            case '/trip_ended':
              return new FromRightToLeft(
                  builder: (_) => new _tripEndedPage.TripEnded(),
                  settings: settings);

            case '/user_reviews':
              return new FromRightToLeft(
                  builder: (_) => new _userReviewsPage.UserReviews(),
                  settings: settings);
            case '/car_reviews':
              return new FromRightToLeft(
                  builder: (_) => new _carReviewsPage.CarReviews(),
                  settings: settings);
            case '/inspection_completed':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _inspectionCompletedPage.InspectionCompleted(),
                  settings: settings);
            case '/discover_car_map':
              return new FromRightToLeft(
                  builder: (_) => new _discoverCarMap.DiscoverCarMap(),
                  settings: settings);
            case '/swap_car_map':
              return new FromRightToLeft(
                  builder: (_) => new _swapCarMap.SwapCarMap(),
                  settings: settings);
            case '/car_details_non_search':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _carDetailsNonSearch.CarDetailsNonSearch(),
                  settings: settings);
            case '/terms_and_conditions':
              return new FromRightToLeft(
                  builder: (_) => new _termsAndConditions.TermsAndCondition(),
                  settings: settings);
            case '/verify_phone_number_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _verifyPhoneNumberUi.VerifyPhoneNumberUi(),
                  settings: settings);
            case '/verify_security_code_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _verifySecurityCodeUi.VerifySecurityCodeUi(),
                  settings: settings);
            case '/terms_and_conditions_ui':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _termsAndConditionsUI.TermsAndConditionUi(),
                  settings: settings);
            case '/receipt':
              return new FromRightToLeft(
                  builder: (_) => new _receiptPage.Receipt(),
                  settings: settings);
            case '/receipt_list':
              return new FromRightToLeft(
                  builder: (_) => new _receiptListPage.ReceiptListPage(),
                  settings: settings);
            case '/latest_receipt':
              return new FromRightToLeft(
                  builder: (_) => new _latestReceiptPage.LatestReceiptPage(),
                  settings: settings);
            case '/receipt_swap':
              return new FromRightToLeft(
                  builder: (_) => new _receiptSwapPage.ReceiptSwap(),
                  settings: settings);
            case '/swap_preferences_tab':
              return new FromRightToLeft(
                  builder: (_) => new _swapPreferencesTab.SwapPreferencesTab(),
                  settings: settings);
            case '/swap_preferences':
              return new FromRightToLeft(
                  builder: (_) => new _swapPreferences.SwapPreferences(),
                  settings: settings);
            case '/swap_car_details':
              return new FromRightToLeft(
                  builder: (_) => new _swapCarDetails.SwapCarDetails(),
                  settings: settings);
            case '/chance_to_swap':
              return new FromRightToLeft(
                  builder: (_) => new _chanceToSwap.ChancesToSwap(),
                  settings: settings);
            case '/swap_arrange_terms':
              return new FromRightToLeft(
                  builder: (_) => new _swapArrangeTerms.SwapArrangeTerms(),
                  settings: settings);
            case '/agree_with_swap_terms':
              return new FromRightToLeft(
                  builder: (_) => new _agreeWithSwapTerms.AgreeWithSwapTerms(),
                  settings: settings);
            case '/swap_trip_booked':
              return new FromRightToLeft(
                  builder: (_) => new _swapTripBooked.SwapTripBooked(),
                  settings: settings);
            case '/swap_duration':
              return new FromRightToLeft(
                  builder: (_) => new _swapDuration.SwapDuration(),
                  settings: settings);
            case '/swap_location':
              return new FromRightToLeft(
                  builder: (_) => new _swapLocation.SwapLocation(),
                  settings: settings);
            case '/swap_insurance':
              return new FromRightToLeft(
                  builder: (_) => new _swapInsurance.SwapInsurance(),
                  settings: settings);
            case '/forgot_password':
              return new FromRightToLeft(
                  builder: (_) => new _forgotPasswordPage.ForgotPassword(),
                  settings: settings);
            case '/calendar_picker':
              return new FromRightToLeft(
                  builder: (_) => new _calendarPicker.CalendarPicker(),
                  settings: settings);
            case '/trip_vehicle_ownership':
              return new FromRightToLeft(
                  builder: (_) =>
                      new _vehicleOwnerShipUI.TripVehicleOwnerShip(),
                  settings: settings);
          }
        },
      ),
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    AppEventsUtils.logEvent("error_triggered",
        params: {"error_message": error.toString()});
  });
}

EventBus eventBus = EventBus();
//constants

//profile Status utils

//profile incomplete indicator

String firebaseCampaign = "";
final ValueNotifier<bool> newMessage = ValueNotifier<bool>(false);
final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);
GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
bool socketOn = false;
UnreadNotificationResponse? unreadNotification;

Future checkFirstTime() async {
  bool updated = await checkVersion();
  if (updated) {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('first_run') ?? true) {
      return IntroPage();
    } else {
      return Tabs();
    }
  } else {
    return VersionAlert();
  }
}

Future<bool> checkVersion() async {
  final FirebaseRemoteConfig remoteConfig = await FirebaseRemoteConfig.instance;
  final defaults = <String, dynamic>{'version': '0.0.0'};
  await remoteConfig.setDefaults(defaults);
  remoteConfig.activate();
  await remoteConfig.fetch(
      // expiration: const Duration(seconds: 0)
      );
  await remoteConfig.activate();
  String forceUpdateCurrentVersion = remoteConfig.getString('version');
  double newVersion =
      double.parse(forceUpdateCurrentVersion.trim().replaceAll(".", ""));
  print(newVersion);
  double oldVersion = await getVersion();
  print(oldVersion);
  if (oldVersion < newVersion) {
    return false;
  }
  return true;
}

Future<RestApi.Resp> fetchUnreadNotifications(userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getUnreadNotificationByUserIDUrl,
    json.encode({
      "UserID": userID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<double> getVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return double.parse(packageInfo.version.trim().replaceAll(".", ""));
}

Object onBackPressed() {
  return showDialog(
        context: NavigationService.navigationKey.currentContext!,
        builder: (context) => new AlertDialog(
          backgroundColor: Colors.white,
          title: new Text('Are you sure?'),
          content: new Text('Do you want to exit App'),
          actions: <Widget>[
            new GestureDetector(
              onTap: () => {Navigator.of(context).pop()},
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("NO")),
            ),
            SizedBox(height: 16),
            new GestureDetector(
              onTap: () => SystemNavigator.pop(animated: true),
              child: TextButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      exit(0);
                    } else {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    }
                  },
                  child: Text("YES")),
            ),
          ],
        ),
      ) ??
      false;
}

class FromRightToLeft<T> extends MaterialPageRoute<T> {
  FromRightToLeft({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new SlideTransition(
      child: new Container(
        decoration: new BoxDecoration(boxShadow: [
          new BoxShadow(
            color: Colors.black26,
            blurRadius: 25.0,
          )
        ]),
        child: child,
      ),
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(new CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Tabs extends StatefulWidget {
  @override
  State createState() => TabsState();
}

class TabsState extends State<Tabs> with LifecycleMixin {
  int _tab = 0;

  // bool _loggedIn;
  // bool _hasCar;
  CreateProfileResponse? res;
  AddIdentityImagesResponse? image;

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  final storage = FlutterSecureStorage();

  //final _scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription? messageSubscription;
  StreamSubscription? inboxSubscription;

  // callFetchLoginState() async {
  //   // TODO first run check
  //
  //
  //
  //   //
  //
  //   String route = await storage.read(key: 'route');
  //   if (route != null && route.isNotEmpty) {
  //     var data = await storage.read(key: 'data');
  //     await storage.delete(key: 'route');
  //     await storage.delete(key: 'data');
  //
  //     if (data == null) {
  //       Navigator.pushNamed(context, route);
  //     } else {
  //       Navigator.pushNamed(context, route, arguments: data);
  //     }
  //     return;
  //   }
  //
  //
  //
  //   String token = await storage.read(key: 'user_id');
  //   String jwt = await storage.read(key: 'jwt');
  //
  //   if (token != null) {
  //     if (jwt != null) {
  //       getBadgeCount();
  //       print("************************************");
  //       /*Future.delayed(Duration(seconds: 1), () {
  //         SocketClient.init().then((value) async {
  //           print("connected");
  //         });
  //       });*/
  //       print("************************************");
  //       var _cars = await fetchUserCars(token, jwt);
  //       if (json.decode(_cars.body!)['Cars'].length > 0) {
  //         setState(() {
  //           _hasCar = true;
  //         });
  //       } else {
  //         setState(() {
  //           _hasCar = false;
  //         });
  //       }
  //
  //       setState(() {
  //         _loggedIn = true;
  //       });
  //
  //     } else {
  //       setState(() {
  //         _loggedIn = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _loggedIn = false;
  //     });
  //   }
  // }
  Future<bool> _onWillPop() async {
    if (ProfileStatus.isLoggedIn) {
      if (_tab != 0) {
        setState(() {
          _tab = 0;
        });
        return false;
      } else {
        if (Platform.isAndroid) {
          SystemNavigator.pop(animated: true);
        } else {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
        return true;
      }
    } else {
      if (_tab != 0) {
        setState(() {
          _tab = 0;
        });
        return false;
      } else {
        if (Platform.isAndroid) {
          SystemNavigator.pop(animated: true);
        } else {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
        return true;
      }
    }
  }

  var _loggedInPages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _tripsViewUI.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  var _loggedInHadCarPages = [
    new _discoverTab.Discover(),
    new _dashboardTab.Dashboard(),
    new _tripsViewUI.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  var _loggedOutPages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _createProfileOrSignInViewTab.CreateProfileOrSignInView(),
  ];

  @override
  Widget build(BuildContext context) {
    print("tab from main method : " + _tab.toString());
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Color(0xffFFFFFF),
        key: scaffoldKey,
        body: (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
            ? _loggedInHadCarPages[_tab]
            : (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
                ? _loggedInPages[_tab]
                : _loggedOutPages[_tab],
        // body: _loggedOutPages[_tab],

        //map button
        floatingActionButton: _tab == 0
            ? StreamBuilder<bool>(
                stream: MapButtonBloc.mapButtonStream,
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data!
                      ? MapButton(
                          onPressed: () async {
                            // TODO map click issue
                            if (!_mapClick) {
                              _mapClick = true;
                              var _newCarData =
                                  await discoverBloc.callFetchNewCars();
                              Navigator.pushNamed(context, '/discover_car_map',
                                      arguments: _newCarData)
                                  .then((value) => _mapClick = false);
                            }
                          },
                        )
                      : Container();
                },
              )
            : Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        //Tabs
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontFamily: 'Urbanist', fontSize: 11),
          )),
          child: NavigationBar(
            //
            backgroundColor: Colors.white,
            indicatorColor: Color(0xffFFd2bd),
            // // selectedItemColor: Color.fromRGBO(55, 29, 50, 1),
            selectedIndex: _tab,
            height:65,
            onDestinationSelected: onTap,
            destinations: (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
                ? [
                    NavigationDestination(
                      icon: SvgPicture.asset(
                        'svg/discoverIcon.svg',
                        color: Colors.grey,
                        height: 28,
                      ),
                      selectedIcon: SvgPicture.asset(
                        'svg/discoverIcon.svg',
                        color: Colors.black,
                        height: 28,
                      ),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.av_timer,
                        color: Colors.grey,
                        size: 28,
                      ),
                      selectedIcon: Icon(
                        Icons.av_timer,
                        color: Colors.black,
                        size: 28,
                      ),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.compare_arrows,
                        color: Colors.grey,
                        size: 28,
                      ),
                      selectedIcon: Icon(
                        Icons.compare_arrows,
                        color: Colors.black,
                        size: 28,
                      ),
                      label: 'Trips',
                    ),
                    NavigationDestination(
                      icon: ValueListenableBuilder(
                        builder:
                            (BuildContext context, bool value, Widget? child) {
                          return value
                              ? Stack(
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: Colors.grey,
                                      size: 28,
                                    ),
                                    Positioned(
                                      left: 12,
                                      child: Container(
                                        height: 12.5,
                                        width: 12.5,
                                        decoration: BoxDecoration(
                                          color: Color(0xffFF8F68),
                                          border: Border.all(
                                            color: Color(0xffFF8F68),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Icon(
                                  Icons.message,
                                  color: Colors.grey,
                                  size: 28,
                                );
                        },
                        valueListenable: newMessage,
                      ),
                      selectedIcon: Icon(
                        Icons.message,
                        color: Colors.black,
                        size: 28,
                      ),
                      label: 'Inbox',
                    ),
                    NavigationDestination(
                      icon: ValueListenableBuilder(
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          print("=============print from main1");
                          return value == 0 && ProfileStatus.isProfileComplete
                              ? Icon(
                                  Icons.account_circle_rounded,
                                  color: Colors.grey,
                                  size: 28,
                                )
                              : Stack(
                                  children: [
                                    Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.grey,
                                      size: 28,
                                    ),
                                  ],
                                );
                        },
                        valueListenable: notificationCount,
                      ),
                      selectedIcon: ValueListenableBuilder(
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          print("=============print from main2");
                          return value == 0 && ProfileStatus.isProfileComplete
                              ? Icon(
                                  Icons.account_circle_rounded,
                                  color: Colors.black,
                                  size: 28,
                                )
                              : Stack(
                                  children: [
                                    Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ],
                                );
                        },
                        valueListenable: notificationCount,
                      ),
                      label: ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
                    ),
                  ]
                : (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
                    ? [
                        NavigationDestination(
                          icon: SvgPicture.asset(
                            'svg/discoverIcon.svg',
                            color: Colors.grey,
                            height: 28,
                          ),
                          selectedIcon: SvgPicture.asset(
                            'svg/discoverIcon.svg',
                            color: Colors.black,
                            height: 28,
                          ),
                          label: 'Discover',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.app_registration,
                            color: Colors.grey,
                            size: 28,
                          ),
                          selectedIcon: Icon(
                            Icons.app_registration,
                            color: Colors.black,
                            size: 28,
                          ),
                          label: 'List your car',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.compare_arrows,
                            color: Colors.grey,
                            size: 28,
                          ),
                          selectedIcon: Icon(
                            Icons.compare_arrows,
                            color: Colors.black,
                            size: 28,
                          ),
                          label: 'Trips',
                        ),
                        NavigationDestination(
                          icon: ValueListenableBuilder(
                            builder: (BuildContext context, bool value,
                                Widget? child) {
                              return value
                                  ? Stack(
                                      children: [
                                        Icon(
                                          Icons.message,
                                          color: Colors.black,
                                          size: 28,
                                        ),
                                        Positioned(
                                          left: 10,
                                          child: Container(
                                            height: 12.5,
                                            width: 12.5,
                                            decoration: BoxDecoration(
                                              color: Color(0xffFF8F68),
                                              border: Border.all(
                                                color: Color(0xffFF8F68),
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Icon(
                                      Icons.message,
                                      color: Colors.grey,
                                      size: 28,
                                    );
                            },
                            valueListenable: newMessage,
                          ),
                          selectedIcon: Icon(
                            Icons.message,
                            size: 28,
                            color: Colors.black,
                          ),
                          label: 'Chats',
                        ),
                        NavigationDestination(
                          icon: ValueListenableBuilder(
                            builder:
                                (BuildContext context, int value, Widget? child) {
                              print("=============print from main3");
                              return value == 0 && ProfileStatus.isProfileComplete
                                  ? Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.grey,
                                      size: 28,
                                    )
                                  : Stack(
                                      children: [
                                        Icon(
                                          Icons.account_circle_rounded,
                                          color: Colors.grey,
                                          size: 28,
                                        ),
                                      ],
                                    );
                            },
                            valueListenable: notificationCount,
                          ),
                          selectedIcon: ValueListenableBuilder(
                            builder:
                                (BuildContext context, int value, Widget? child) {
                              print("=============print from main4");
                              return value == 0 && ProfileStatus.isProfileComplete
                                  ? Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.black,
                                      size: 28,
                                    )
                                  : Stack(
                                      children: [
                                        Icon(
                                          Icons.account_circle_rounded,
                                          color: Colors.grey,
                                          size: 28,
                                        ),
                                      ],
                                    );
                            },
                            valueListenable: notificationCount,
                          ),
                          label: ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
                        ),
                      ]
                    : [
                        NavigationDestination(
                          icon: SvgPicture.asset(
                            'svg/discoverIcon.svg',
                            color: Colors.grey,
                            height: 28,
                          ),
                          selectedIcon: SvgPicture.asset(
                            'svg/discoverIcon.svg',
                            color: Colors.black,
                            height: 28,
                          ),
                          label: 'Discover',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.app_registration,
                            size: 28,
                            color: Colors.grey,
                          ),
                          selectedIcon: Icon(
                            Icons.app_registration,
                            size: 28,
                            color: Colors.black,
                          ),
                          label: 'List your car',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.account_circle_rounded,
                            size: 28,
                            color: Colors.grey,
                          ),
                          selectedIcon: Icon(
                            Icons.account_circle_rounded,
                            size: 28,
                            color: Colors.black,
                          ),
                          label: ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
                        ),
                      ],
          ),
        ),
      ),
    );
  }

  void checkStatus() async {
    String? profileID = await storage.read(key: 'profile_id');

    if (profileID != null) {
      var res2 = await fetchProfileVerificationData(profileID);

      var _profileVerificationData = json.decode(res2.body!)['Verification'];

      print(_profileVerificationData.toString());

      if (_profileVerificationData['EmailVerification']['VerificationStatus'] ==
          'Verified') {
        // print('profile yes verify! ' + DateTime.now().toString());
        var data = await storage.read(key: 'verify');
        print(data);
        if (data == null || data != "done") {
          // final snackBar = SnackBar(content: Text('Email Verification Successful!'),);
          // _scaffoldKey.currentState.showSnackBar(snackBar);
          await storage.write(key: "verify", value: "done");
        }
      } else {
        print('profile not verify! ' + DateTime.now().toString());
        await storage.write(key: "verify", value: "undone");
      }
    }
  }

  Future<RestApi.Resp> checkUnreadNotificationStatus(userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      changeUnreadNotificationStatusUrl,
      json.encode({
        "UserID": userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  @override
  void dispose() {
    //BackButtonInterceptor.remove(myInterceptor);
    messageSubscription!.cancel();
    inboxSubscription!.cancel();
    SocketClient.disconnect();
    super.dispose();
  }

  Future<RestApi.Resp> fetchProfileVerificationData(_profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getVerificationStatusByProfileIDUrl,
      json.encode({
        "ProfileID": _profileID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<http.Response> fetchUserCars(param, jwt) async {
    final response = await http.post(
      Uri.parse(getCarsByUserIDUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
      body: json.encode({"UserID": param}),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void getBadgeCount() async {
    try {
      //String count = await storage.read(key: "count");
      final prefs = await SharedPreferences.getInstance();
      String? count = prefs.getString("count");
      notificationCount.value = int.tryParse(count!)!;
      FlutterAppBadger.updateBadgeCount(notificationCount.value);
    } catch (e) {
      print(e);
    }
  }

  void getThreadList() async {
    try {
      var msgToSend = {
        "token": await storage.read(key: 'jwt'),
        "userId": await storage.read(key: 'user_id'),
      };
      var dataToSend = {"dataType": "InitData", "data": msgToSend};
      print(jsonEncode(dataToSend));
      SocketClient.send(dataToSend);
    } catch (e) {
      print(e);
    }
  }

  getUnreadNotification() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var unreadResponse = await fetchUnreadNotifications(userID);

      unreadNotification = UnreadNotificationResponse.fromJson(
          json.decode(unreadResponse.body!));
      if (unreadNotification != null &&
          unreadNotification!.totalCount != null &&
          unreadNotification!.totalCount != '0') {
        int? count = int.tryParse(unreadNotification!.totalCount!);
        notificationCount.value = count!;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("count", notificationCount.value.toString());

        //await storage.write(key: "count", value: notificationCount.value.toString());

        FlutterAppBadger.updateBadgeCount(notificationCount.value);
      }
      print('unread${unreadNotification!.totalCount}');
    }
  }

  void initDynamicLinks() async {
    print("initDynamicLinks");
    FirebaseDynamicLinks.instance.onLink;

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      try {
        print(deepLink);
        firebaseCampaign = deepLink.toString().split("=")[1];
        print(firebaseCampaign);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    checkVersion();

    //AppEventsUtils.init();
    initDynamicLinks();

    // profile status
    ProfileStatus.init().then((value) => setState(() {}));

    //BackButtonInterceptor.add(myInterceptor);
    //getBadgeCount();
    setUpEventBus();
    // _loggedIn = false;
    // _hasCar = false;
    // callFetchLoginState();
    getUnreadNotification();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!");
    onBackPressed();
    return true;
  }

  @override
  void onPause() {
    // TODO: implement onPause
    print("notification:::${notificationCount.value}");
    FlutterAppBadger.updateBadgeCount(notificationCount.value);
  }

  @override
  void onResume() {
    // TODO: implement onResume
    print('hello from tabs!' + DateTime.now().toString());
    checkStatus();
  }

  void onTap(int tab) {
    if (tab == 4) ProfileStatus.init().whenComplete(() => setState(() {}));

    setState(() {
      _tab = tab;
    });
  }

  void setUpEventBus() async {
    String? userId = await storage.read(key: 'user_id');
    inboxSubscription =
        EventBusUtils.getInstance().on<InboxEvent>().listen((event) {
      print("InboxListener:::");
      try {
        var data = event.data;
        var threadData = data["data"];
        if (threadData["threads"] != null) {
          List threadList = threadData["threads"];
          for (var threadItem in threadList) {
            List<Message> messages = [];
            if (threadItem["messages"] != null) {
              List messageList = threadItem["messages"];
              print("**********************");
              print(threadItem["user1_read"]);
              print(threadItem["user2_read"]);
              print("**********************");
              for (var message in messageList) {
                print(message);
                if (message["messageType"] == "Text") {
                  messages.add(
                    Message(
                      threadId: message["threadId"],
                      senderId: message["senderId"],
                      receiverId: message["receiverId"],
                      message: message["messageBody"],
                      type: message["messageType"],
                      time: message["createdAt"],
                    ),
                  );
                } else if (message["messageType"] == "Image") {
                  messages.add(
                    Message(
                      threadId: message["threadId"],
                      senderId: message["senderId"],
                      receiverId: message["receiverId"],
                      message: "Image",
                      type: "Image",
                      time: message["createdAt"],
                    ),
                  );
                } else if (message["messageType"] == "SwapAgreementCard") {
                  messages.add(
                    Message.swap(
                      threadId: message["threadId"],
                      senderId: message["senderId"],
                      receiverId: message["receiverId"],
                      message: "SwapAgreementCard",
                      type: "SwapAgreementCard",
                      time: message["createdAt"],
                      swap: Swap(
                        userId: message["senderId"],
                        agreementId: message["messageBody"],
                      ),
                    ),
                  );
                } else {}
              }
            }

            Thread thread = Thread(
                id: threadItem["threadId"].toString(),
                userId: threadItem["userId1"] == userId
                    ? threadItem["userId2"]
                    : threadItem["userId1"],
                name: "Loading Name...",
                message: messages.length > 0 ? messages[0].message : "",
                time: threadItem["updatedAt"],
                image: "",
                seen: threadItem["userId1"] == userId
                    ? threadItem["user1_read"]
                    : threadItem["user2_read"],
                messages: messages);

            if (!thread.seen) {
              newMessage.value = true;
            }
          }
        }
      } catch (e) {
        print(e);
      }
    });

    messageSubscription =
        EventBusUtils.getInstance().on<MessageEvent>().listen((event) {
      print("main:::MessageListener:::");
      newMessage.value = false;
      SocketClient.restart();
    });
  }
}
