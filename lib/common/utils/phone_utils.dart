/// Helpers for turning free-typed phone input into the E.164 format that
/// Firebase Phone Auth requires ("+263771234567").
///
/// ZimDate targets Zimbabwe, so the country code defaults to +263, but any
/// country code can still be typed.
library;

/// Zimbabwe's country calling code.
const String kDefaultCountryCode = '263';

/// Shortest national number we accept (after any trunk prefix is stripped).
const int kMinNationalDigits = 6;

/// Longest national number we accept. E.164 caps the whole number at 15
/// digits, and the country code takes 1-4 of those.
const int kMaxNationalDigits = 12;

class PhoneNumber {
  PhoneNumber(this.e164, this.countryCode, this.national);

  /// Full number in E.164 form, ready to hand to Firebase.
  final String e164;

  /// Country calling code without the leading '+'.
  final String countryCode;

  /// National significant number, trunk prefix removed.
  final String national;

  @override
  String toString() => e164;
}

/// Why a raw phone number was rejected.
enum PhoneNumberProblem { empty, tooShort, tooLong, badCountryCode }

class PhoneUtils {
  PhoneUtils._();

  static final RegExp _nonDigits = RegExp(r'\D');

  /// Strips everything that is not a digit: spaces, dashes, parens, '+'.
  static String digitsOnly(String value) => value.replaceAll(_nonDigits, '');

  /// Builds an E.164 number from the two raw text fields.
  ///
  /// Handles the formats people actually type:
  ///   country "263"  + number "771234567"   -> +263771234567
  ///   country "263"  + number "0771234567"  -> +263771234567
  ///   country "263"  + number "0771 234 567"-> +263771234567
  ///   country ""     + number "771234567"   -> +263771234567 (defaulted)
  static PhoneNumber build({
    String? countryCode,
    String? phoneNumber,
    String fallbackCountryCode = kDefaultCountryCode,
  }) {
    final ccDigits = digitsOnly(countryCode ?? '');
    final country = ccDigits.isEmpty ? fallbackCountryCode : ccDigits;

    // A leading 0 is a national trunk prefix, not part of the number.
    // Sending +2630771234567 to Firebase fails; +263771234567 works.
    final national = digitsOnly(phoneNumber ?? '').replaceFirst(RegExp(r'^0+'), '');

    return PhoneNumber('+$country$national', country, national);
  }

  /// Returns null when the number is usable, otherwise why it is not.
  static PhoneNumberProblem? validate(PhoneNumber number) {
    if (number.national.isEmpty) return PhoneNumberProblem.empty;
    if (number.national.length < kMinNationalDigits) {
      return PhoneNumberProblem.tooShort;
    }
    if (number.national.length > kMaxNationalDigits) {
      return PhoneNumberProblem.tooLong;
    }
    // Country calling codes are 1-4 digits (ITU-T E.164).
    if (number.countryCode.isEmpty || number.countryCode.length > 4) {
      return PhoneNumberProblem.badCountryCode;
    }
    return null;
  }
}
