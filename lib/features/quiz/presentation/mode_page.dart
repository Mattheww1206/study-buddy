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
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "STUDY BUDDY",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.face, color: Colors.white),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 35),

              // --- SUBJECT CARD ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B80F0), Color(0xFF665FBE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("1 / 20", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                          const SizedBox(width: 10),
                          Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(width: 15, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("Subject Name", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.orange, size: 8),
                            SizedBox(width: 8),
                            Text("Last Studied | 2 days ago", style: TextStyle(color: Colors.white, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text("Choose Study Mode", style: TextStyle(color: Color(0xFF665FBE), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // --- FLASHCARD MODE BUTTON ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'flashcard_mode');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D0074),
                    elevation: 2,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF2F1FF), borderRadius: BorderRadius.circular(15)),
                        child: const Icon(Icons.style, color: Colors.orange, size: 30),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Flashcard Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("Flip cards to study terms", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // --- QUIZ MODE BUTTON ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'quiz_mode');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D0074),
                    elevation: 2,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.redAccent, size: 45),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quiz Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("Test yourself with questions", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      Icon(Icons.check_box, color: Color(0xFF5AD69B), size: 30),
                      Icon(Icons.check_box, color: Color(0xFF5AD69B), size: 30),
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