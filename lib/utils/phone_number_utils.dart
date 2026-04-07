import 'package:flutter/services.dart';

class PhoneNumberUtils {
  static const int mobileLength = 10;

  static final List<TextInputFormatter> inputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(mobileLength),
  ];

  static String? validateMobile(String? value) {
    final mobile = value?.trim() ?? "";
    if (mobile.isEmpty) {
      return "Please enter your mobile number";
    }
    if (mobile.length != mobileLength) {
      return "Please enter a valid 10-digit mobile number";
    }
    return null;
  }

  static bool isValidMobile(String? value) {
    return validateMobile(value) == null;
  }
}
