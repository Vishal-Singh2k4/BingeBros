import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final AppBar? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? titleTextColor;
  final Color? backgroundColor; // Added backgroundColor parameter
  
  const BaseScaffold({
    Key? key,
    required this.body,
    this.title,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.titleTextColor,
    this.backgroundColor, // Added backgroundColor initialization
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = Color(0xFF9166FF);
    final Gradient backgroundGradient = isDarkMode
        ? LinearGradient(
            colors: [Colors.black, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.white, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    // Set title text color based on the theme if not provided
    final Color effectiveTitleTextColor = titleTextColor ?? (isDarkMode ? Colors.white : Colors.black);

    return Scaffold(
      appBar: appBar ??
          (title != null
              ? AppBar(
                  title: Text(
                    title!,
                    style: TextStyle(
                      color: effectiveTitleTextColor, // Use calculated title text color
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )
              : null),
      body: Container(
        color: backgroundColor, // Use backgroundColor if provided
        decoration: backgroundColor == null
            ? BoxDecoration(
                gradient: backgroundGradient,
              )
            : null,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
