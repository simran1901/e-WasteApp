import 'package:e_waste_app/screens/products_overview_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth_screen.dart';
// import 'package:imiego/screens/choose_screen.dart';
// import 'package:imiego/screens/tab_screen.dart';

class VerificationScreen extends StatelessWidget {
  static String routeName = '/verification-screen';
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
              child: Text(
                  'Email verification link has been sent to your email address. Verify your email to continue.'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor),
              ),
              child: Text('Confirm Verification'),
              onPressed: () async {
                try {
                  User user = FirebaseAuth.instance.currentUser;
                  await user.reload();
                  user = FirebaseAuth.instance.currentUser;
                  if (!user.emailVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Email not verified! Check your mailbox.',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.black54,
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (ctx) => ProductsOverviewScreen()));
                } catch (e) {
                  return e.message;
                }
              },
            ),
            TextButton(
              child: Text(
                'Edit your credentials',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                user.delete();
                Navigator.of(context)
                    .pushReplacementNamed(AuthScreen.routeName);
              },
            ),
            TextButton(
              child: Text(
                'Resend link',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                user.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email sent to the given email address.',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.black54,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
