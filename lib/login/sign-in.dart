import 'package:bluetooth_low_energy/login/component/button.dart';
import 'package:bluetooth_low_energy/login/component/textfield.dart';
import 'package:bluetooth_low_energy/login/sign-up.dart';
import 'package:bluetooth_low_energy/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // @override
  // void dispose() {
  //   super.dispose();
  //   usernameController.dispose();
  //   passwordController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Image.asset(
                          'assets/logo.png',
                          width: 170,
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        Mytextfield(
                          controller: usernameController,
                          hintText: 'Email',
                          obscureText: false,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Mytextfield(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Mybutton(
                            onTap: () async {
                              await AuthService().signin(
                                  email: usernameController.text,
                                  password: passwordController.text,
                                  context: context);
                            },
                            text: 'LOGIN'),
                        const SizedBox(
                          height: 40,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dont have an account?',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Signup(),
                                      ));
                                },
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
