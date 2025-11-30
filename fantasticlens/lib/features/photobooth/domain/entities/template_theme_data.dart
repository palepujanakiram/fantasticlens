class TemplateThemeData {
  const TemplateThemeData({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundGradient,
  });

  /// Primary brand color represented as ARGB hex (e.g. 0xFF123456).
  final int primaryColor;

  /// Accent color represented as ARGB hex.
  final int accentColor;

  /// Gradient colors represented as ARGB hex values.
  final List<int> backgroundGradient;
}

