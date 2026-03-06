import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FF),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // --- 1. PINNED DECKS ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              // DITO ANG FIX: Naglagay tayo ng padding sa buong container
              // para ang scroll area ay hindi sasayad sa gilid.
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 15),
                    child: Row(
                      children: [
                        const Icon(Icons.push_pin,
                            color: Colors.redAccent, size: 24),
                        const SizedBox(width: 10),
                        Text("Pinned decks",
                            style: GoogleFonts.lora(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // Scroll View Area
                  SizedBox(
                    height: 150,
                    child: ListView( // Ginamit ang ListView para mas kontrolado ang padding
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Card 1
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF8E84FF),
                              Color(0xFF6C63FF)
                            ]),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.push_pin,
                                      color: Colors.redAccent, size: 20)),
                              Text("Mathematics",
                                  style: GoogleFonts.lora(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                              const SizedBox(height: 8),
                              Text("45 Flashcards",
                                  style: GoogleFonts.lora(
                                      color: Colors.black87, fontSize: 16)),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Card 2
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF8E84FF),
                              Color(0xFF6C63FF)
                            ]),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.push_pin,
                                      color: Colors.redAccent, size: 20)),
                              Text("Science & Tech",
                                  style: GoogleFonts.lora(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                              const SizedBox(height: 8),
                              Text("32 Flashcards",
                                  style: GoogleFonts.lora(
                                      color: Colors.black87, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. STATS CONTAINER ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 35),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(35)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("12",
                          style: GoogleFonts.lora(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 158, 154, 241))),
                      Text("DECKS CREATED",
                          style: GoogleFonts.lora(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Container(height: 40, width: 2, color: Colors.grey[100]),
                  Column(
                    children: [
                      Text("24",
                          style: GoogleFonts.lora(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 158, 154, 241))),
                      Text("QUIZ TAKEN",
                          style: GoogleFonts.lora(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 3. PROGRESS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    height: 175,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(35)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Continue Last Session!",
                            style: GoogleFonts.lora(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("85% Progress",
                              style: GoogleFonts.lora(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        const SizedBox(height: 12),
                        Text("Modern History",
                            style: GoogleFonts.lora(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
            // --- 4. RECENT DECKS ---
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Recent Decks",
                        style: GoogleFonts.lora(
                            fontSize: 22, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 15),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 182, 164, 224),
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Major Subject",
                          style: GoogleFonts.lora(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("50 Cards",
                          style: GoogleFonts.lora(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // --- 5. NEWLY ADDED DECKS ---
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Newly added decks",
                        style: GoogleFonts.lora(
                            fontSize: 22, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 15),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.purple.shade100, width: 1.5)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New Subject",
                          style: GoogleFonts.lora(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("15 Cards",
                          style: GoogleFonts.lora(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
          ]
        ),
      
      ),
    );
  }
}