import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Mytextfield extends StatelessWidget {
  const Mytextfield(
      {super.key,
      this.controller,
      required this.hintText,
      required this.obscureText});
  final controller;
  final String hintText;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            fillColor: Colors.white,
            filled: true,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.outline,
            )),
      ),
    );
  }
}
