import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';

/// Adaptive scaffold that shows a permanent drawer on large screens
/// and a temporary drawer on small screens
class AdaptiveScaffold extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final Color? appBarBackgroundColor;
  final Widget drawerContent;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    this.actions,
    this.appBarBackgroundColor,
    required this.drawerContent,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = ResponsiveConstants.isLargeScreen(constraints.maxWidth);

        if (isLargeScreen) {
          // Large screen: permanent drawer + content area
          return Scaffold(
            appBar: AppBar(
              title: title,
              backgroundColor: appBarBackgroundColor,
              actions: actions,
              automaticallyImplyLeading: false, // Hide hamburger icon
            ),
            body: Row(
              children: [
                // Permanent drawer
                SizedBox(
                  width: ResponsiveConstants.permanentDrawerWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: drawerContent,
                  ),
                ),
                // Content area
                Expanded(
                  child: body,
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
          );
        } else {
          // Small screen: traditional drawer
          return Scaffold(
            appBar: AppBar(
              title: title,
              backgroundColor: appBarBackgroundColor,
              actions: actions,
            ),
            drawer: Drawer(
              child: drawerContent,
            ),
            body: body,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
          );
        }
      },
    );
  }
}
