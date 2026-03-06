import 'package:flutter/material.dart';

class QuizModePage extends StatefulWidget {
  const QuizModePage({super.key});

  @override
  State<QuizModePage> createState() => _QuizModePageState();
}

class _QuizModePageState extends State<QuizModePage> {
  String selectedType = 'Multiple Choice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF5E5CE6), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz Mode',
          style: TextStyle(color: Color(0xFF120E32), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Biology Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFF4C49A7),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Column(
                children: [
                  Text('BIOLOGY', style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Cell Division', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('20 cards available', style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('Choose Quiz Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF120E32))),
            const SizedBox(height: 20),

            // 1. Multiple Choice
            GestureDetector(
              onTap: () => setState(() => selectedType = 'Multiple Choice'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selectedType == 'Multiple Choice' ? const Color(0xFF5E5CE6) : Colors.grey.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF7B78E1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.edit_document, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Multiple Choice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Choose 1 correct answer from 4 options', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (selectedType == 'Multiple Choice') const Icon(Icons.check_circle, color: Color(0xFF5E5CE6)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Chip(label: Text('⚡ Most Common', style: TextStyle(fontSize: 10, color: Color(0xFF5E5CE6), fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFF0EFFF), side: BorderSide.none),
                        SizedBox(width: 8),
                        Chip(label: Text('🎯 Good for Beginners', style: TextStyle(fontSize: 10, color: Color(0xFF5E5CE6), fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFF0EFFF), side: BorderSide.none),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // 2. Identification
            GestureDetector(
              onTap: () => setState(() => selectedType = 'Identification'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selectedType == 'Identification' ? const Color(0xFF5E5CE6) : Colors.grey.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFFFF9DB), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.keyboard, color: Color(0xFFD4AC0D), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Identification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Type the correct answer yourself', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (selectedType == 'Identification') const Icon(Icons.check_circle, color: Color(0xFF5E5CE6)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Chip(label: Text('🧠 Tests Memory', style: TextStyle(fontSize: 10, color: Color(0xFFD4AC0D), fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFFFF9DB), side: BorderSide.none),
                        SizedBox(width: 8),
                        Chip(label: Text('💪 More Challenging', style: TextStyle(fontSize: 10, color: Color(0xFFD4AC0D), fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFFFF9DB), side: BorderSide.none),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // 3. Random Mix
            GestureDetector(
              onTap: () => setState(() => selectedType = 'Random Mix'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selectedType == 'Random Mix' ? const Color(0xFF5E5CE6) : Colors.grey.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.casino, color: Color(0xFF2E7D32), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Random Mix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Mix of both types, randomly shuffled', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (selectedType == 'Random Mix') const Icon(Icons.check_circle, color: Color(0xFF5E5CE6)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Chip(label: Text('🔀 Keeps You Sharp', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFE8F5E9), side: BorderSide.none),
                        SizedBox(width: 8),
                        Chip(label: Text('⭐ Recommended', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFE8F5E9), side: BorderSide.none),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Start Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8137),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Start Quiz →', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}