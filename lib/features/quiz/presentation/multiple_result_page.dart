import 'package:flutter/material.dart';

class MultipleResultPage extends StatefulWidget {
  const MultipleResultPage({super.key});

  @override
  State<MultipleResultPage> createState() => _MultipleResultPageState();
}

class _MultipleResultPageState extends State<MultipleResultPage> {
  @override
  Widget build(BuildContext context) {
    const Color dominantColor = Color(0xFF665FBE);
    const Color secondaryColor = Color(0xFFFAEEFF);
    const Color accentColor = Color(0xFFFF7900);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [dominantColor, Color(0xFF7A73D1)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "QUIZ COMPLETE!",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const Icon(Icons.emoji_events, size: 45, color: Colors.white),
              ),
              const SizedBox(height: 5),
              const Text(
                "90%",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const Text(
                "Excellent Work! 🎉",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  "📄 Multiple Choice • 10 Questions • Biology",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25), 
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    // Pinalitan ang spaceBetween ng start para umakyat ang content
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: [
                      // Total Score Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F7FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8E5FF)),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "9/10",
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: dominantColor),
                            ),
                            Text(
                              "TOTAL SCORE",
                              style: TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Accuracy Progress Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F7FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8E5FF)),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bar_chart_rounded, color: dominantColor, size: 20),
                                    SizedBox(width: 8),
                                    Text("Accuracy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Text("90%", style: TextStyle(fontWeight: FontWeight.bold, color: dominantColor)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                value: 0.9,
                                minHeight: 10,
                                backgroundColor: Color(0xFFE0E0E0),
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Time and Streak Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F7FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8E5FF)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.timer_outlined, color: Colors.black26, size: 22),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("14m 22s", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text("TIME USED", style: TextStyle(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F7FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE8E5FF)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.local_fire_department, color: accentColor, size: 22),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("+1 day", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text("STREAK", style: TextStyle(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // --- SPACE BAGO ANG BUTTONS (Binawasan para itaas sila) ---
                      const SizedBox(height: 25), 
                      
                      // 1. Review Wrong Answer Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor, 
                          foregroundColor: secondaryColor, 
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 20),
                            SizedBox(width: 10),
                            Text("Review Wrong Answer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 2. Back to Deck Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor, 
                          foregroundColor: secondaryColor, 
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: 10),
                            Text("Back to Deck", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      
                      // Pinaka-bottom space (Binawasan mula 30+ ginawang 20 para umakyat lahat)
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}