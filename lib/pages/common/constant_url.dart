//Stage Url //
const uxcamKey = "esvhkbxldm8cpt4";
const mixpanelToken = "8d5d1ccb5a63707f985cfa83a6642213";
const userServerUrl = 'https://api.user.stg.ridealike.com';
const profileServerUrl = 'https://api.profile.stg.ridealike.com';
const carServerUrl = 'https://api.car.stg.ridealike.com';
const discoverServerUrl = 'https://api.discover.stg.ridealike.com';
const calendarServerUrl = 'https://api.calendar.stg.ridealike.com';
const paymentServerUrl = 'https://api.payment.stg.ridealike.com';
const tripServerUrl = 'https://api.trip.stg.ridealike.com';
const faqServerUrl = 'https://api.faq.stg.ridealike.com';
const miscServerUrl = 'https://api.misc.stg.ridealike.com';
const notificationServerUrl = 'https://api.notification.stg.ridealike.com';
const storageServerUrl = 'https://api.storage.stg.ridealike.com';
const bookingServerUrl = 'https://api.booking.stg.ridealike.com';
const socketServerUrl = 'http://api.messaging.stg.ridealike.com/ws';
const String carDetailsLink = 'https://stg.ridealike.com/page/car-details/';
const getAvailableCouponUrl = 'https://api.misc.stg.ridealike.com/v1/misc.MiscService/GetBookingCoupons';

// Production base_url //
/*const uxcamKey = "d3perwav3qcihr6";
const mixpanelToken = "7b2f40be2d6e0c7fffdbc99f9a2d166e";
const userServerUrl = 'https://api.user.ridealike.com';
const profileServerUrl = 'https://api.profile.ridealike.com';
const carServerUrl = 'https://api.car.ridealike.com';
const discoverServerUrl = 'https://api.discover.ridealike.com';
const calendarServerUrl = 'https://api.calendar.ridealike.com';
const paymentServerUrl='https://api.payment.ridealike.com';
const tripServerUrl='https://api.trip.ridealike.com';
const faqServerUrl='https://api.faq.ridealike.com';
const miscServerUrl='https://api.misc.ridealike.com';
const notificationServerUrl ='https://api.notification.ridealike.com';
const storageServerUrl ='https://api.storage.ridealike.com';
const bookingServerUrl ='https://api.booking.ridealike.com';
const socketServerUrl ='http://api.messaging.ridealike.com/ws';
const carDetailsLink = 'https://ridealike.com/page/car-details/';*/
//const getAvailableCouponUrl = 'https://api.misc.ridealike.com/v1/misc.MiscService/GetBookingCoupons';



//google API -Key//
const googleApiKeyUrl = 'AIzaSyBe1q5KOK3dPzBAdwkDer_n_YLLuMhBHkQ';
const senecaUrl = "http://apiaistg.ridealike.com/validate/";

// create profile url//
const acceptTermsAndConditionsUrl_userServer =
    '$profileServerUrl/v1/profile.ProfileService/AcceptTermsAndConditions';
const acceptPromotionalUpdatesUrl_userServer =
    '$profileServerUrl/v1/profile.ProfileService/AcceptPromotionalUpdates';
const acceptTermsAndConditionsUrl_profileServer =
    '$profileServerUrl/v1/profile.ProfileService/AcceptTermsAndConditions';
const acceptPromotionalUpdatesUrl_profileServer =
    '$profileServerUrl/v1/profile.ProfileService/AcceptPromotionalUpdates';
const addPhoneNumberUrl =
    '$profileServerUrl/v1/profile.ProfileService/AddPhoneNumber';
const sendPhoneVerificationCodeUrl =
    '$profileServerUrl/v1/profile.ProfileService/SendPhoneVerificationCode';
const addIdentityImageUrl =
    '$profileServerUrl/v1/profile.ProfileService/AddIdentityImage';
const addDLFrontImageUrl =
    '$profileServerUrl/v1/profile.ProfileService/AddDLFrontImage';
const addDLBackImageUrl =
    '$profileServerUrl/v1/profile.ProfileService/AddDLBackImage';
const getAllUrl = '$faqServerUrl/v1/faq.FAQService/GetAll';
const sendOTPUrl = '$profileServerUrl/v1/profile.ProfileService/SendOTP';
const getProfileVerificationUrl =
    '$profileServerUrl/v1/profile.ProfileService/GetProfileVerification';
const sendWelcomeEmailUrl =
    '$userServerUrl/v1/user.UserService/SendWelcomeEmail';
const getDropDownValueUrl =
    '$miscServerUrl/v1/misc.MiscService/GetAllHeardOptions';

// user login url//
const loginUrl = '$userServerUrl/v1/user.UserService/Login';
const socialLoginUrl = '$userServerUrl/v1/user.UserService/SocialLogin';
const deleteUserUrl = '$userServerUrl/v1/user.UserService/DeleteUserByID';
const changeFirstName = '$userServerUrl/v1/user.UserService/UpdateFirstName';
const changeLastName = '$userServerUrl/v1/user.UserService/UpdateLastName';

//list a car//
const createCarUrl = '$carServerUrl/v1/car.CarService/CreateCar';
const getListCarBannerUrl =
    '$miscServerUrl/v1/misc.MiscService/GetListCarBanner';
const getAllModelForListACarUrl =
    '$carServerUrl/v1/car.CarService/GetAllModelForListACar';
const getAllBodyTrimForListACarUrl =
    '$carServerUrl/v1/car.CarService/GetAllBodyTrimForListACar';
const getCalendarByOwnerIDUrl =
    '$calendarServerUrl/v1/calendar.CalendarService/GetCalendarByOwnerID';
const blockMultipleDaysUrl =
    '$calendarServerUrl/v1/calendar.CalendarService/BlockMultipleDays';
const unBlockMultipleDaysUrl =
    '$calendarServerUrl/v1/calendar.CalendarService/UnBlockMultipleDays';
const getCalendarUrl =
    '$calendarServerUrl/v1/calendar.CalendarService/GetCalendar';
const requestToVerifyUrl = '$carServerUrl/v1/car.CarService/RequestToVerify';
const deleteCarUrl = '$carServerUrl/v1/car.CarService/DeleteCar';
const getListCarConfigurablesUrl =
    '$carServerUrl/v1/car.CarService/GetListCarConfigurables';
const getSuggestedPricingByCarIDUrl =
    '$carServerUrl/v1/car.CarService/GetSuggestedPricingByCarID';
const getAllStyleForListACarUrl =
    '$carServerUrl/v1/car.CarService/GetAllStyleForListACar';
const setListingTypeUrl = '$carServerUrl/v1/car.CarService/SetListingType';

//Discover(Rent &swap)//
const getNewCarsUrl =
    '$discoverServerUrl/v1/discover.DiscoverService/GetNewCars';
const getPopularCarsUrl =
    '$discoverServerUrl/v1/discover.DiscoverService/GetPopularCars';
const getLastViewedCarsUrl =
    '$discoverServerUrl/v1/discover.DiscoverService/GetLastViewedCars';
const getLastBookedCarsUrl =
    '$discoverServerUrl/v1/discover.DiscoverService/GetLastBookedCars';
const addCarToViewedListUrl =
    '$discoverServerUrl/v1/discover.DiscoverService/AddCarToViewedList';
const getNewSwapCarsList =
    '$discoverServerUrl/v1/discover.DiscoverService/GetNewSwapCars';

//Trips//
const cancelTripUrl = '$tripServerUrl/v1/trip.TripService/CancelTrip';
const inspectTripStartUrl =
    '$tripServerUrl/v1/trip.TripService/InspectTripStartHost';
const startTripUrl = '$tripServerUrl/v1/trip.TripService/StartTrip';
const guestinspectTripStartUrl =
    '$tripServerUrl/v1/trip.TripService/InspectTripStart';
const endTripUrl = '$tripServerUrl/v1/trip.TripService/EndTrip';
const inspectTripEndRentalUrl =
    '$tripServerUrl/v1/trip.TripService/InspectTripEndRental';
const rateTripCarUrl = '$tripServerUrl/v1/trip.TripService/RateTripCar';
const rateTripHostUrl = '$tripServerUrl/v1/trip.TripService/RateTripHost';
const inspectTripEndRentoutUrl =
    '$tripServerUrl/v1/trip.TripService/InspectTripEndRentout';
const rateTripGuestUrl = '$tripServerUrl/v1/trip.TripService/RateTripGuest';
const requestReimbursementUrl =
    '$tripServerUrl/v1/trip.TripService/RequestReimbursement';
const getTripByIDUrl = '$tripServerUrl/v1/trip.TripService/GetTripByID';
const getProfileByUserIDUrl =
    '$profileServerUrl/v1/profile.ProfileService/GetProfileByUserID';
const createChangeRequestUrl =
    "$tripServerUrl/v1/trip.TripService/CreateTripUpdateChange";
const getChangeRequestUrl = "$tripServerUrl/v1/trip.TripService/GetTripChange";
const getChangeRequestAcceptUrl =
    "$tripServerUrl/v1/trip.TripService/AcceptTripChange";
const getChangeRequestRejectUrl =
    "$tripServerUrl/v1/trip.TripService/DeleteTripChange";
const getInspectionInfoUrl =
    "$tripServerUrl/v1/trip.TripService/GetInspectionInfoByTripID";
const inspectionStart =
    "$tripServerUrl/v1/trip.TripService/inspectionStart";
const guestgetInspectionInfoUrl =
    "$tripServerUrl/v1/trip.TripService/InspectTripStart";
const getInsuranceAndRoadSideAssistNumbersUrl =
    '$miscServerUrl/v1/misc.MiscService/GetInsuranceAndRoadSideAssistNumbers';
const getRentAgreementUrl = '$carServerUrl/v1/car.CarService/GetRentAgreement';
const inspectTripStartHost =
    '$tripServerUrl/v1/trip.TripService/InspectTripStartHost';
const inspectStart =
    '$tripServerUrl/v1/trip.TripService/InspectStart';

// car details//
const showLocationUrl = '$tripServerUrl/v1/trip.TripService/ShowLocation';

// profile //
const getProfileUrl = '$profileServerUrl/v1/profile.ProfileService/GetProfile';
const getVerificationStatusByProfileIDUrl =
    '$profileServerUrl/v1/profile.ProfileService/GetVerificationStatusByProfileID';
const getNumberOfRatingsByProfileIDUrl =
    '$profileServerUrl/v1/profile.ProfileService/GetNumberOfRatingsByProfileID';
const getCardsByUserIDUrl =
    '$paymentServerUrl/v1/payment.PaymentService/GetCardsByUserID';
const getUnreadNotificationByUserIDUrl =
    '$notificationServerUrl/v1/notification.NotificationService/GetUnreadNotificationByUserID';
const changeUnreadNotificationStatusUrl =
    '$notificationServerUrl/v1/notification.NotificationService/ChangeUnreadNotificationStatus';
const addAboutMeUrl = '$profileServerUrl/v1/profile.ProfileService/AddAboutMe';
const getNotificationByUserIDUrl =
    '$notificationServerUrl/v1/notification.NotificationService/GetNotificationByUserID';
const updateEmailUrl = '$userServerUrl/v1/user.UserService/UpdateEmail';
const sendEmailVerificationLinkUrl =
    '$userServerUrl/v1/user.UserService/SendEmailVerificationLink';
const getNotificationSettingUrl =
    '$notificationServerUrl/v1/notification.NotificationService/GetNotificationSetting';
const setNotificationSettingUrl =
    '$notificationServerUrl/v1/notification.NotificationService/SetNotificationSetting';
const addCardUrl = '$paymentServerUrl/v1/payment.PaymentService/AddCard';
const updatePasswordUrl = '$userServerUrl/v1/user.UserService/UpdatePassword';
const verifyPhoneUrl =
    '$profileServerUrl/v1/profile.ProfileService/VerifyPhone';
const getCarsByUserIDUrl = '$carServerUrl/v1/car.CarService/GetCarsByUserID';
const uploadUrl = '$storageServerUrl/upload';
const addProfileImageUrl =
    '$profileServerUrl/v1/profile.ProfileService/AddProfileImage';
const feedbackUrl = '$miscServerUrl/v1/misc.MiscService/Feedback';
const registerUrl = '$userServerUrl/v1/user.UserService/Register';
const getPayoutMethodUrl =
    '$paymentServerUrl/v1/payment.PaymentService/GetPayoutMethod';
const setPayoutMethodUrl =
    '$paymentServerUrl/v1/payment.PaymentService/SetPayoutMethod';
const getAllReviewByUserIDUrl =
    '$profileServerUrl/v1/profile.ProfileService/GetAllReviewByUserID';
const getProfilesByUserIDsUrl =
    '$profileServerUrl/v1/profile.ProfileService/GetProfilesByUserIDs';
const updateIdentityVerificationUrl =
    '$profileServerUrl/v1/profile.ProfileService/UpdateIdentityVerification';
const submitProfileStatusUrl =
    '$profileServerUrl/v1/profile.ProfileService/SubmitProfile';

//Covid Checklist
const getCovidChecklistUrl =
    '$miscServerUrl/v1/misc.MiscService/GetCovidChecklist';

// swap //
const getSwapArgeementTermsUrl =
    "$carServerUrl/v1/car.CarService/GetSwapArgeementTerms";
const getAgreedSwapTripsStatusUrl =
    "$tripServerUrl/v1/trip.TripService/GetAgreedSwapTripsStatus";
const agreeSwapAgreementUrl =
    "$carServerUrl/v1/car.CarService/AgreeSwapAgreement";
const updateSwapArgeementTermsUrl =
    "$carServerUrl/v1/car.CarService/UpdateSwapArgeementTerms";
const calcSwapArgeementTermsPricingUrl =
    "$carServerUrl/v1/car.CarService/CalcSwapArgeementTermsPricing";
const getTripsByUserIDUrl =
    "$tripServerUrl/v1/trip.TripService/GetTripsByUserID";
const swapCarUrl = "$carServerUrl/v1/car.CarService/SwapCar";
const getAllSwapAvailabilityByUserIDUrl =
    "$carServerUrl/v1/car.CarService/GetAllSwapAvailabilityByUserID";
const getSwapRecommendationUrl =
    "$carServerUrl/v1/car.CarService/GetSwapRecommendation";
const setSwapAvailabilityUrl =
    "$carServerUrl/v1/car.CarService/SetSwapAvailability";
const setCarToSwapUrl = "$carServerUrl/v1/car.CarService/SetCarToSwap";
const getSwapBannerUrl = "$miscServerUrl/v1/misc.MiscService/GetSwapBanner";

// dashboard //
const getAllCarModelUrl = '$carServerUrl/v1/car.CarService/GetAllCarModel';
const getAllTransactionByUserIDUrl =
    '$bookingServerUrl/v1/booking.BookingService/GetAllTransactionByUserID';
const getAllTransactionByCarIDUrl =
    '$bookingServerUrl/v1/booking.BookingService/GetAllTransactionByCarID';
const getAllReviewByCarIDsUrl =
    '$carServerUrl/v1/car.CarService/GetAllReviewByCarIDs';
const getAllReviewByCarIDUrl =
    '$carServerUrl/v1/car.CarService/GetAllReviewByCarID';
const getAllUserTripsByStatusGroupUrl =
    '$tripServerUrl/v1/trip.TripService/GetAllUserTripsByStatusGroup';
const getCarUrl = '$carServerUrl/v1/car.CarService/GetCar';
const getCarsByCarIDsUrl = '$carServerUrl/v1/car.CarService/GetCarsByCarIDs';
const getBookingByIDUrl =
    '$bookingServerUrl/v1/booking.BookingService/GetBookingByID';
const getAllCarTypeUrl = '$carServerUrl/v1/car.CarService/GetAllCarType';
const getAllCarStyleUrl = '$carServerUrl/v1/car.CarService/GetAllCarStyle';
const setImagesAndDocumentsUrl =
    '$carServerUrl/v1/car.CarService/SetImagesAndDocuments';
const getAllCarBodyTrimUrl =
    '$carServerUrl/v1/car.CarService/GetAllCarBodyTrim';
const getAllCarMakeUrl = '$carServerUrl/v1/car.CarService/GetAllCarMake';
const setAvailabilityUrl = '$carServerUrl/v1/car.CarService/SetAvailability';
const setFeaturesUrl = '$carServerUrl/v1/car.CarService/SetFeatures';
const setAboutUrl = '$carServerUrl/v1/car.CarService/SetAbout';
const setPreferenceUrl = '$carServerUrl/v1/car.CarService/SetPreference';
const setPricingUrl = '$carServerUrl/v1/car.CarService/SetPricing';
const getAllProvinceUrl = '$carServerUrl/v1/car.CarService/GetAllProvince';
const getInsuranceAndInfoCardUrl =
    '$miscServerUrl/v1/misc.MiscService/GetInsuranceAndInfoCard';

// search //
const getAllEnlistedCarMakesUrl =
    '$carServerUrl/v1/car.CarService/GetAllEnlistedCarMakes';
const getAllEnlistedCarModelsUrl =
    '$carServerUrl/v1/car.CarService/GetAllEnlistedCarModels';
const searchCarUrl = '$carServerUrl/v1/car.CarService/SearchCar';
const getAllEnlistedCarTypesUrl =
    '$carServerUrl/v1/car.CarService/GetAllEnlistedCarTypes';

// booking //
const viewCalendarEventsUrl =
    '$calendarServerUrl/v1/calendar.CalendarService/ViewCalendarEvents';
const getPricingUrl = '$bookingServerUrl/v1/booking.BookingService/GetPricing';
const initBookingUrl =
    '$bookingServerUrl/v1/booking.BookingService/InitBooking';

// terms_conditions_policy //
const getCodeOfConductUrl =
    '$miscServerUrl/v1/misc.MiscService/GetCodeOfConduct';
const getPrivacyPolicyUrl =
    '$miscServerUrl/v1/misc.MiscService/GetPrivacyPolicy';
const getTermsAndConditionsUrl =
    '$miscServerUrl/v1/misc.MiscService/GetTermsAndConditions';

// forgot password //
const forgotPasswordUrl = '$userServerUrl/v1/user.UserService/ForgotPassword';

// tabs //
const setNotificationTokenUrl =
    '$notificationServerUrl/v1/notification.NotificationService/SetNotificationToken';

const getSwapCalendarEventsUrl =
    "$calendarServerUrl/v1/calendar.CalendarService/ViewSwapCalendarEvents";

//blog
const blogUrl = 'https://www.ridealike.com/blog';

//terms of service
const termsOfServiceUrl = 'https://www.ridealike.com/page/termsofservice';

//privacy policy
const privacyPolicyUrl = 'https://www.ridealike.com/privacypolicy';

//Code of Conduct
const codeOfConductUrl = 'https://www.ridealike.com/page/codeofconduct';

//covid checklist
const covidChecklist = 'https://www.ridealike.com/page/covid-checklist';

//Insurance Policy
const insurancePolicyUrl =
    'http://northbridgeinsurance.ca/specialty-solutions/sharing-economy-insurance/ridealike-carsharing-insurance/';

//Refer a friend
const referAFriend = 'https://www.ridealike.com/refer-a-friend';

//FAQ
const faqUrl = 'https://www.ridealike.com/faq';

/// Contact Us
const contactUsUrl = 'https://www.ridealike.com/page/contact-us';

/// Northbridge submitted link

const northBridgeSubmittedUrl =
    'https://www.northbridgeinsurance.ca/submit-a-claim/';

///covid sanitization link//
const covidSanitizationdUrl = 'https://homeautosan.com/ridealike/';

/// ridealike policy //
const rideAlikePoliciesCBCurl =
    'https://www.northbridgeinsurance.ca/specialty-solutions/sharing-economy-insurance/ridealike-carsharing-insurance/';
