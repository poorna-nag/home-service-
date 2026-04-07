import 'package:flutter_test/flutter_test.dart';
import 'package:EcoShine24/utils/phone_number_utils.dart';

void main() {
  test('accepts only valid 10-digit mobile numbers', () {
    expect(PhoneNumberUtils.validateMobile('9876543210'), isNull);
    expect(
      PhoneNumberUtils.validateMobile('98765'),
      'Please enter a valid 10-digit mobile number',
    );
    expect(
      PhoneNumberUtils.validateMobile(''),
      'Please enter your mobile number',
    );
  });
}
