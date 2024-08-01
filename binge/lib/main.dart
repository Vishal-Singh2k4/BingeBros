import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binge/routes/routes.dart';
import 'package:binge/providers/auth_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Binge',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: authProvider.isLoggedIn ? Routes.home : Routes.splash,
            onGenerateRoute: Routes.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
