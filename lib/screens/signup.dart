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
