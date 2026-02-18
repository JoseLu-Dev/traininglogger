import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';

/// Adaptive scaffold that shows a permanent drawer on large screens
/// and a temporary drawer on small screens
class AdaptiveScaffold extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? appBarBackgroundColor;
  final Widget drawerContent;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final PreferredSizeWidget? bottom;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.appBarBackgroundColor,
    this.bottom,
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
              leading: leading,
              title: title,
              backgroundColor: appBarBackgroundColor,
              actions: actions,
              automaticallyImplyLeading: leading == null, // Hide hamburger icon if no custom leading
              bottom: bottom,
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
              leading: leading,
              title: title,
              backgroundColor: appBarBackgroundColor,
              actions: actions,
              bottom: bottom,
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
