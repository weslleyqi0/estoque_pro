class DateParser {
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return DateTime.fromMillisecondsSinceEpoch(intValue);
      }
      return DateTime.tryParse(value);
    }
    
    return null;
  }
}
