import 'package:flutter_test/flutter_test.dart';
import 'package:zimdate/common/utils/phone_utils.dart';

void main() {
  group('PhoneUtils.build', () {
    test('defaults to the Zimbabwe country code when none is entered', () {
      final n = PhoneUtils.build(phoneNumber: '771234567');
      expect(n.e164, '+263771234567');
    });

    test('strips the trunk zero from a local-format number', () {
      final n = PhoneUtils.build(countryCode: '263', phoneNumber: '0771234567');
      expect(n.e164, '+263771234567');
    });

    test('removes spaces, dashes and parentheses', () {
      final n = PhoneUtils.build(countryCode: '263', phoneNumber: '0771 234 567');
      expect(n.e164, '+263771234567');
    });

    test('strips a leading plus from the country code', () {
      final n = PhoneUtils.build(countryCode: '+263', phoneNumber: '771234567');
      expect(n.e164, '+263771234567');
    });

    test('keeps a non-Zimbabwe country code', () {
      final n = PhoneUtils.build(countryCode: '44', phoneNumber: '7400123456');
      expect(n.e164, '+447400123456');
    });

    test('leaves the country code field alone when blank', () {
      final n = PhoneUtils.build(countryCode: '', phoneNumber: '771234567');
      expect(n.countryCode, '263');
      expect(n.e164, '+263771234567');
    });
  });

  group('PhoneUtils.validate', () {
    test('accepts a normal Zimbabwe mobile number', () {
      final n = PhoneUtils.build(countryCode: '263', phoneNumber: '0771234567');
      expect(PhoneUtils.validate(n), isNull);
    });

    test('rejects an empty number', () {
      expect(
        PhoneUtils.validate(PhoneUtils.build(phoneNumber: '')),
        PhoneNumberProblem.empty,
      );
    });

    test('rejects a number that is too short', () {
      expect(
        PhoneUtils.validate(PhoneUtils.build(phoneNumber: '123')),
        PhoneNumberProblem.tooShort,
      );
    });

    test('accepts the longest allowed number', () {
      final longest = List.filled(12, '1').join();
      final n = PhoneUtils.build(phoneNumber: longest);
      expect(PhoneUtils.validate(n), isNull);
      expect(n.e164, '+263$longest');
    });

    test('rejects a number that is too long', () {
      final tooLong = List.filled(13, '1').join();
      expect(
        PhoneUtils.validate(PhoneUtils.build(phoneNumber: tooLong)),
        PhoneNumberProblem.tooLong,
      );
    });

    test('rejects a country code longer than 4 digits', () {
      expect(
        PhoneUtils.validate(PhoneUtils.build(countryCode: '12345', phoneNumber: '771234567')),
        PhoneNumberProblem.badCountryCode,
      );
    });
  });
}
