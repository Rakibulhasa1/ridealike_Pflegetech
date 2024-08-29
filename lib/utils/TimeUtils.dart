class TimeUtils {
  static String formatSliderTime(int time) {
    String result = "";
    if (time == 0) {
      result = "12:00 AM";
    } else if (time >= 1 && time <= 11) {
      result = time.toString() + ":00 AM";
    } else if (time == 12) {
      result = time.toString() + ":00 PM";
    } else if (time >= 13 && time <= 23) {
      result = (time - 12).toString() + ":00 PM";
    }
    return result;
  }

  static String getSliderTime(int time) {
    String result = "";
    if (time >= 0 && time <= 9) {
      result = "0" + time.toString();
    } else if (time >= 10 && time <= 23) {
      result = time.toString();
    }
    return result;
  }
}
