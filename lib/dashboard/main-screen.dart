// import 'package:bluetooth_low_energy/bluetooth/bluetooth_route.dart';
import 'package:bluetooth_low_energy/bluetooth/bluetooth_constant.dart';
import 'package:bluetooth_low_energy/bluetooth/bluetooth_wrapper.dart';
import 'package:bluetooth_low_energy/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class Mainscreen extends StatefulWidget {
  List<MyBluetoothData> datanya;
  Mainscreen({super.key, required this.datanya});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    // Ambil email saat widget diinisialisasi
    getUserEmail();
  }

  void getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail =
          user?.email ?? 'Unknown User'; // Default jika tidak ada pengguna
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String bpmtext;
    String oksigentext;
    String status;
    if (widget.datanya.isEmpty) {
      bpmtext = "0";
      oksigentext = "0";
      status = 'NORMAL';
    } else {
      // widget.datanya.sort((a, b) => b.date.compareTo(a.date));
      bpmtext = widget.datanya.first.bpm.toString();
      oksigentext = widget.datanya.first.oksigen.toString();

      if (widget.datanya.first.bpm < 60) {
        status = "BRADYCARDIA";
      } else if (widget.datanya.first.bpm > 100) {
        status = "TACHYCARDIA";
      } else {
        status = "NORMAL";
      }
    }
    Size size = MediaQuery.sizeOf(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffF7C35A),
                          ),
                        ),
                        Image.asset(
                          'assets/user.png',
                          width: 24,
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome!',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.outline)),
                        Text(userEmail ?? 'Loading',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BluetoothScan(),
                              ));
                        },
                        icon: Image.asset(
                          'assets/bt.png',
                          width: 35,
                        )),
                    IconButton(
                        onPressed: () async {
                          await AuthService().signout(context: context);
                        },
                        icon: Image.asset(
                          'assets/logout.png',
                          width: 35,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: size.width,
              height: size.height / 4.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15), // warna shadow
                    spreadRadius: 2, // ukuran shadow
                    blurRadius: 20, // ketajaman shadow
                    offset: Offset(0, 3), // posisi shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Status',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(status,
                      style: GoogleFonts.poppins(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 30),
              child: Row(
                children: [
                  Text('Data',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: size.width,
                height: size.height / 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/oxy.png',
                            width: 50,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('Oxygen',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Row(
                        children: [
                          Text(oksigentext,
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              )),
                          const SizedBox(
                            width: 8,
                          ),
                          Text('%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                width: size.width,
                height: size.height / 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/hr.png',
                            width: 50,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('Heart Rate',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Row(
                        children: [
                          Text(bpmtext,
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              )),
                          const SizedBox(
                            width: 8,
                          ),
                          Text('bpm',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 23, bottom: 10),
              child: Row(
                children: [
                  Text('History',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
              // reverse: true,
              itemCount: widget.datanya.length,
              itemBuilder: (BuildContext context, int index) {
                var appsFormat = DateFormat('yyyy-MM-dd, hh:mm:ss');
                String dateApps = appsFormat.format(widget.datanya[index].date);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/ht.png',
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Oxygen',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              )),
                                          Text('Heart Rate',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              )),
                                          Text('Time',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 2,
                                right: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      widget.datanya[index].oksigen.toString() +
                                          ' %',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      )),
                                  Text(
                                      widget.datanya[index].bpm.toString() +
                                          ' bpm',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      )),
                                  Text(dateApps,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
