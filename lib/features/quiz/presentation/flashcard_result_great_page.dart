import 'package:flutter/material.dart';

class FlashcardResultGreatPage extends StatefulWidget {
  const FlashcardResultGreatPage({super.key});

  @override
  State<FlashcardResultGreatPage> createState() => _FlashcardResultGreatPageState();
}

class _FlashcardResultGreatPageState extends State<FlashcardResultGreatPage> {
  // Dito mo i-input ang counts
  final int gotItCount = 14;
  final int hardCount = 3;
  final int againCount = 3;

  @override
  Widget build(BuildContext context) {
    // LOGIC PARA SA ACCURACY
    int totalCards = gotItCount + hardCount + againCount;
    // Accuracy = (Got It / Total)
    double accuracyRatio = totalCards > 0 ? gotItCount / totalCards : 0.0;
    int accuracyPercentage = (accuracyRatio * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Section
            const Text(
              'Flashcard Mode',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Biology • Cell Division',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            const Text(
              'Amazing Session!',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            // Ginawang dynamic ang total cards text
            Text(
              'You went through all $totalCards cards',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // White Card Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top Row Stats (Got it, Hard, Again)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Got It Box
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Text('$gotItCount', style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                                const Text('GOT IT!', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                          // Hard Box
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Text('$hardCount', style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold)),
                                const Text('HARD', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                          // Again Box
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)),
                              child: Column(children: [
                                Text('$againCount', style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                                const Text('AGAIN', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Accuracy Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFFF3F2FF), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Accuracy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('$accuracyPercentage%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: accuracyRatio,
                              backgroundColor: Colors.deepPurple[50],
                              color: const Color(0xFF6C63FF),
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // XP Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFF5E548E), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('XP Earned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('+${gotItCount * 10} XP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Study Again', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF27F21), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // --- ETO NA ANG BINAGO ---
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // DITO NILAGAY ANG NAVIGATION:
                            Navigator.pushNamed(context, 'missed');
                          },
                          icon: const Icon(Icons.push_pin, color: Color(0xFF6C63FF)),
                          label: Text('Review Missed ($againCount)', style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3E5F5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                      // -------------------------

                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Mark as Done', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
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