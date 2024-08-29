import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateUtil {
  static final instance = DateUtil();

  String formatDate(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = inputFormat.parse(date);
    DateFormat outputFormat = DateFormat("MM/dd/yyyy");
    String dateInString = outputFormat.format(dateTime);
    return dateInString;
  }

  String formatBookDate(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    String dateInString = dateTime.toUtc().toIso8601String();
    return dateInString;
  }

  String formatMessageDate(String date) {
    String dateInString = "";
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    DateTime current = DateTime.now();

    if (current.difference(dateTime).inDays > 7) {
      DateFormat outputFormat = DateFormat("MMM d");
      dateInString = outputFormat.format(dateTime);
    } else if (current.difference(dateTime).inDays >= 1 &&
        current.difference(dateTime).inDays <= 7) {
      DateFormat outputFormat = DateFormat("E");
      dateInString = outputFormat.format(dateTime);
    } else if (current.difference(dateTime).inHours > 1 &&
        current.difference(dateTime).inDays <= 23) {
      DateFormat outputFormat = DateFormat("hh:mm a");
      dateInString = outputFormat.format(dateTime);
    } else {
      dateInString = timeago.format(dateTime, locale: 'en');
    }

    return dateInString;
  }

  String formatSwapDate(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    DateFormat outputFormat = DateFormat("MMM d, yyyy, hh:00 a");
    String dateInString = outputFormat.format(dateTime);
    return dateInString;
  }

  String formatMessageGroupDate(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    DateFormat outputFormat = DateFormat("d MMM yyyy");
    String dateInString = outputFormat.format(dateTime);
    return dateInString;
  }

  String formatMessageTime(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    DateFormat outputFormat = DateFormat("hh:mm a");
    String dateInString = outputFormat.format(dateTime);
    print(date + ":::" + dateTime.toIso8601String());
    return dateInString;
  }

  DateTime getSwapDate(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    return dateTime;
  }

  String formatSwapDateTime(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    DateFormat outputFormat = DateFormat("MMM d, hh:mm a");
    String dateInString = outputFormat.format(dateTime);
    return dateInString;
  }

  String getMessageTime() {
    DateFormat outputFormat = DateFormat("HH:mm a");
    String dateInString = outputFormat.format(DateTime.now());
    return dateInString;
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    //print(startDate);
    //print(endDate);
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
      //print("getDaysInBetween:::" + days.toString());
    }
    if (days.length > 0) {
      DateTime start = DateTime.utc(
          days[0].year,
          days[0].month,
          days[0].day,
          startDate.hour,
          startDate.minute,
          startDate.second,
          startDate.millisecond,
          startDate.microsecond);
      days.removeAt(0);
      days.insert(0, start);
      DateTime end = DateTime.utc(
          days[days.length - 1].year,
          days[days.length - 1].month,
          days[days.length - 1].day,
          endDate.hour,
          endDate.minute,
          endDate.second,
          endDate.millisecond,
          endDate.microsecond);
      //days.removeLast();
      days.add(end);
    }
    //print(days.toString());
    return days;
  }

  bool isValidTime(DateTime givenTime) {
    DateTime validTime = DateTime.now().add(Duration(
      minutes: 50,
    ));
    return givenTime.isAfter(validTime);
  }

  String getFormattedDate(DateTime date){
    DateFormat outputFormat = DateFormat("yyyy-MM-dd");
    String output = outputFormat.format(date);
    print(output);
    return output;
  }

  String formatFreeCancelDateTime(String date) {
    print(date);
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    DateFormat outputFormat = DateFormat("MMM dd, yyyy hh:00 a");
    String dateInString = outputFormat.format(dateTime);
    return dateInString;
  }

  DateTime getFreeCancelDateTime(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    dateTime = dateTime.add(DateTime.now().timeZoneOffset);
    return dateTime;
  }
}
