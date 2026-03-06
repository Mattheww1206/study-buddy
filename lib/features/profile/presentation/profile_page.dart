import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/features/auth/provider/user_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final loggedUser = Provider.of<UserProvider>(context).user; 
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF665FBE), // Dominant
              Color(0xFFFAEEFF)  // Secondary
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF665FBE), 
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/studybuddy-logo.png',
                                    height: 110,
                                    fit: BoxFit.contain,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(context,'settings');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                  
                              // Profile Avatar 
                              const Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: CircleAvatar(
                                  radius: 65,
                                  backgroundColor: Color(0xFFFAEEFF), 
                                  child: CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 90,
                                      color: Color(0xFF665FBE),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  
                          const SizedBox(height: 10),
                  
                          Text(
                            loggedUser?.username ?? 'Foxy',
                            style: GoogleFonts.lora( 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                  
                          const SizedBox(height: 15),
                  
                          // Streak Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFD9519), 
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department, color: Colors.white, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  '15 Day Study Streak',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                  
                // Stats Container
                Transform.translate(
                  offset: const Offset(0, -40), 
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '6', 
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.bold, 
                                fontSize: 25,  
                                color: const Color(0xFF665FBE))),
                            Text(
                              'Decks\nCreated', 
                              textAlign: TextAlign.center, 
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.bold,
                                fontSize: 15, 
                                color: const Color(0xFF665FBE))),
                          ],
                        ),
                        Container(
                          height: 40, 
                          width: 1, 
                          color: Colors.grey.withOpacity(0.3)),
                        Column(
                          children: [
                            Text(
                              '2', 
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.bold,
                                fontSize: 25, 
                                color: const Color(0xFF665FBE))),
                            Text(
                              'Quiz\nCreated', 
                              textAlign: TextAlign.center, 
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.bold,
                                fontSize: 15, 
                                color: const Color(0xFF665FBE))),
                          ],
                        ),
                        Container(
                          height: 40, 
                          width: 1, 
                          color: Colors.grey.withOpacity(0.3)),
                        Column(
                          children: [
                            Text(
                              '4', 
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                 color: const Color(0xFF665FBE))),
                            Text(
                              'Decks\nMastered', 
                              textAlign: TextAlign.center, 
                              style: GoogleFonts.lora( 
                                fontWeight: FontWeight.bold,
                                fontSize: 15, 
                                color: const Color(0xFF665FBE))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                  
                Transform.translate(
                  offset: const Offset(0, -5),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Study (4 / 6)',
                          style: GoogleFonts.lora( 
                            fontWeight: FontWeight.bold,
                            fontSize: 20, 
                             color: const Color(0xFF665FBE)),
                        ),
                        const SizedBox(height: 12),
                        // In-update ang row para sumunod sa sinend mong design
                        Row(
                          children: [
                            const Icon(Icons.check, color: Color(0xFF665FBE), size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 15,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAEEFF), 
                                  borderRadius: BorderRadius.circular(10)),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.57,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF665FBE), 
                                       borderRadius: BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '57%', 
                              style: GoogleFonts.lora( 
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: const Color(0xFF665FBE))),
                          ],
                        ),
                  
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(color: Colors.grey, thickness: 0.5),
                        ),
                  
                        Text(
                          'Weekly Study (10 / 15)',
                          style: GoogleFonts.lora(
                            fontWeight: FontWeight.bold,
                            fontSize: 20, 
                            color: const Color(0xFF665FBE)),
                        ),
                        const SizedBox(height: 12),
                        // In-update ang row para maging isa nalang ang progress bar
                        Row(
                          children: [
                            const Icon(Icons.check, color: Color(0xFF665FBE), size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 15,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAEEFF), 
                                   borderRadius: BorderRadius.circular(10)),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.70,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF665FBE), 
                                      borderRadius: BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '70%', 
                              style: GoogleFonts.lora( 
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: const Color(0xFF665FBE))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}