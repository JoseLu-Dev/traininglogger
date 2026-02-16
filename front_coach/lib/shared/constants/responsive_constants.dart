class ResponsiveConstants {
  static const double tabletBreakpoint = 600.0;
  static const double permanentDrawerWidth = 280.0;

  static bool isLargeScreen(double width) => width >= tabletBreakpoint;
}
