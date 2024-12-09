import 'package:bluetooth_low_energy/services/splash.dart';
import 'package:flutter/material.dart';

// import 'package:smartcap/login/sign-in.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Cap',
      theme: ThemeData(
          colorScheme: const ColorScheme.light(
              surface: Color(0xffF3F4F6),
              onSurface: Colors.black,
              primary: Color(0xff00B2E7),
              secondary: Color(0xff00C4FF),
              tertiary: Color(0xff85E3FF),
              outline: Color(0xffA1B1C6))),
      home: const Splashscreen(),
    );
  }
}
