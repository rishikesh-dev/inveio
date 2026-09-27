/// Returns a time-based greeting string based on the current hour.
String get greeting {
  final hour = DateTime.now().hour;

  return switch (hour) {
    >= 5 && < 12 => 'Good Morning',
    >= 12 && < 17 => 'Good Afternoon',
    _ => 'Good Evening',
  };
}
