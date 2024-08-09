import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binge/providers/AuthProvider.dart';
import 'package:binge/routes/routes.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings Page Content'),
            SizedBox(height: 20),
            authProvider.isLoggedIn
                ? ElevatedButton(
                    onPressed: () async {
                      await authProvider.logout();
                      Navigator.of(context).pushReplacementNamed(Routes.splash);
                    },
                    child: Text('Logout'),
                  )
                : Text('User not logged in'),
          ],
        ),
      ),
    );
  }
}
