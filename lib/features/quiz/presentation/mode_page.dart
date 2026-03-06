import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: ModePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  State<ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "STUDY BUDDY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),
            
            // Main Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Purple Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF665FBE),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text("1 / 20", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                          SizedBox(height: 4),
                          Text("Subject Name", style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Last Studied | 2 days ago", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    
                    // Buttons Section
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          const Text("Choose Study Mode", 
                            style: TextStyle(color: Color(0xFF665FBE), fontSize: 23, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 20),
                          
                          // FLASHCARD MODE BUTTON
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'flashcard_mode');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFAEEFF),
                              elevation: 0,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.style_outlined, color: Color(0xFFFF7A01), size: 28),
                                const SizedBox(width: 12),
                                const Text("Flashcard Mode", style: TextStyle(color: Color(0xFF0D0074), fontWeight: FontWeight.bold, fontSize: 20)),
                                const Spacer(),
                                Row(
                                  children: [
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF7A01), shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                  ],
                                )
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // QUIZ MODE BUTTON
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'quiz_mode');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFAEEFF),
                              elevation: 0,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.stars_rounded, color: Color(0xFFFF7A01), size: 28),
                                SizedBox(width: 12),
                                Text("Quiz Mode", style: TextStyle(color: Color(0xFF0D0074), fontWeight: FontWeight.bold, fontSize: 20)),
                                Spacer(),
                                Icon(Icons.check_circle_outline, color: Color(0xFFFF7A01), size: 22),
                                Icon(Icons.check_circle_outline, color: Color(0xFF0D0074), size: 22),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}