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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Loginheader(),
          const SizedBox(height: 40,),
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
        
        const SizedBox(height: 20,),
        const SignInForm(),
        const SizedBox(height: 20,),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t have an account? ',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Sign In screen
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text(
                  'Sign Up',
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
    );
  }
}