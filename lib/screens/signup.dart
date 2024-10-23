import 'package:chatapp/authentication/signup_form.dart';
import 'package:chatapp/widgets/loginheader.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
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
              height: 10,
            ),
            const Text(
              '      Hey Stranger,',
              style: TextStyle(
                  color: Colors.black, fontSize: 30, fontFamily: 'Kavivanar'),
            ),
            const Text(
              '      Create An Account :)',
              style: TextStyle(
                  color: Colors.black, fontSize: 30, fontFamily: 'Kavivanar'),
            ),
            const SignUpForm(),
            const SizedBox(
              height: 2,
            ),
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
                      'Or sign up with',
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
                onTap: () {
                  // Handle Google Sign-In logic
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
                        'Sign up with Google',
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
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Have an account? ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Sign In screen
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.purple, // Purple theme color for "Sign In"
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
