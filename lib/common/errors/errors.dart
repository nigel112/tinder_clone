abstract class Failture implements Exception{
  String get message;

  
}

class NotAutomaticRetrieved implements Failture{
  final String verificationId;
  @override
  final String message;

  NotAutomaticRetrieved(this.verificationId, this.message);
}

class ErrorLoginPhone implements Failture{
  @override
  final String message;

  /// Raw Firebase Auth error code (e.g. "operation-not-allowed"), kept so it
  /// can be shown to the user or logged. Previously every failure collapsed
  /// into one generic string, which hid the real cause.
  final String? code;

  ErrorLoginPhone(this.message, {this.code});

  @override
  String toString() => code == null ? message : '$code: $message';
}

class FirestoreError implements Failture{
  @override
  final String message;

  FirestoreError(this.message);
}

class TagsUnselected implements Failture{
  @override
  final String message;

  TagsUnselected(this.message);
}