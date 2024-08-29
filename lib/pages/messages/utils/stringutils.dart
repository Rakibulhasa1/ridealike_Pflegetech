class StringUtils {
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}

// class StringUtils{
//
//   static bool isNumeric(String s) {
//     if(s == null) {
//       return false;
//     }
//     return double.parse(s, (e) => null) != null;
//   }
//
// }