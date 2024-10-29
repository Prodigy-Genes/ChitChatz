import 'package:chatapp/authentication/auth.dart';
import 'package:chatapp/authentication/signin_form.dart';
import 'package:chatapp/widgets/loginheader.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 224),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Loginheader(),
            const SizedBox(
              height: 40,
            ),
            const Text(
              '      Welcome,',
              style: TextStyle(
                  color: Colors.black, fontSize: 30, fontFamily: 'Kavivanar'),
            ),
            const Text(
              '      Hop Back Into Your Account :)',
              style: TextStyle(
                  color: Colors.black, fontSize: 30, fontFamily: 'Kavivanar'),
            ),
            const SizedBox(
              height: 20,
            ),
            const SignInForm(),
            const SizedBox(height: 2),

            // Separator line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                      child: Divider(color: Colors.grey[400], thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Or sign in with',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Kavivanar'),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: Colors.grey[400], thickness: 1)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Google Sign-In Button
            Center(
              child: GestureDetector(
                onTap: () async{
                  // Handle Google Sign-In logic
                   await Auth().signInWithGoogle(context);
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kavivanar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sign Up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account? ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Sign Up screen
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.purple, // Purple theme color for "Sign Up"
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
