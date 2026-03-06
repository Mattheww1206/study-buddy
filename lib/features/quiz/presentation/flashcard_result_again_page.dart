import 'package:flutter/material.dart';

class FlashcardResultAgainPage extends StatefulWidget {
  const FlashcardResultAgainPage({super.key});

  @override
  State<FlashcardResultAgainPage> createState() => _FlashcardResultAgainPageState();
}

class _FlashcardResultAgainPageState extends State<FlashcardResultAgainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF43409B), // Dark purple background mula sa image
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Section
            const Text(
              "Flashcard Mode",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Biology • Cell Division",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            const Text("💡", style: TextStyle(fontSize: 50)),
            const SizedBox(height: 10),
            const Text(
              "Keep Practicing!",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "You'll get better each time",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Main White Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      // Stats Row: Got It, Hard, Again
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Got It Box
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(15)),
                            child: const Column(children: [
                              Text("6", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                              Text("GOT IT!", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                            ]),
                          ),
                          // Hard Box
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(15)),
                            child: const Column(children: [
                              Text("4", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                              Text("HARD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ]),
                          ),
                          // Again Box
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(15)),
                            child: const Column(children: [
                              Text("10", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                              Text("AGAIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Accuracy Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFF7F6FF), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Accuracy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF43409B))),
                                Text("30%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                value: 0.3,
                                minHeight: 12,
                                backgroundColor: Color(0xFFE0E0E0),
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Tip Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFF7F6FF), borderRadius: BorderRadius.circular(20)),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("💡 Tip", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF43409B))),
                            SizedBox(height: 5),
                            Text(
                              "Focus on reviewing the 10 cards you missed. Try writing the definitions out loud!",
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Study Again Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A3D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("🔄 Study Again", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Focus on Missed Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // DITO LANG ANG BINAGO:
                            Navigator.pushNamed(context,'missed');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF706FD3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("📌 Focus on Missed (10)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Back to Deck Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD1C4E9)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("← Back to Deck", style: TextStyle(color: Color(0xFF706FD3), fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}