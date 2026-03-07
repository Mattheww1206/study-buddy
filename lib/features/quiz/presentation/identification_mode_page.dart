import 'package:flutter/material.dart';

class IdentificationModePage extends StatefulWidget {
  const IdentificationModePage({super.key});

  @override
  State<IdentificationModePage> createState() => _IdentificationModePageState();
}

class _IdentificationModePageState extends State<IdentificationModePage> {
  bool isTimerEnabled = true;
  int selectedTime = 20;
  int numberOfQuestions = 100;
  final TextEditingController _questionsController = TextEditingController(text: "100");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF665FBE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 36),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Quiz Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // --- SELECTED MODE SECTION (Binago ang Icon at Text) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF665FBE),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SELECTED MODE",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.keyboard, color: Colors.white, size: 26), // Changed to keyboard icon
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Identification",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("Type the correct answer manually",
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- NUMBER OF QUESTIONS SECTION ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: Color(0xFF665FBE), size: 24),
                      SizedBox(width: 8),
                      Text("Number of Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _questionsController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        numberOfQuestions = int.tryParse(val) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 1.6),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 2.0),
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF665FBE)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- QUIZ TIMER SECTION ---
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Color(0xFF2D2D5E), size: 24),
                          SizedBox(width: 8),
                          Text("Quiz Timer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: (val) => setState(() => isTimerEnabled = val),
                        activeColor: const Color(0xFF665FBE),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isTimerEnabled)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [10, 15, 20, 25, 30].map((time) {
                          bool isSelected = selectedTime == time;
                          return GestureDetector(
                            onTap: () => setState(() => selectedTime = time),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF665FBE) : const Color(0xFFFAEEFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${time}m",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF665FBE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- QUIZ SUMMARY SECTION (Binago ang Icon at Text) ---
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("QUIZ SUMMARY",
                      style: TextStyle(color: Color(0xFF665FBE), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      const Icon(Icons.keyboard, color: Color(0xFFFF7F32), size: 28), // Updated Icon
                      const SizedBox(width: 10),
                      const Text("Identification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered, color: Color(0xFF665FBE), size: 28),
                      const SizedBox(width: 10),
                      Text("$numberOfQuestions Questions", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(isTimerEnabled ? Icons.timer : Icons.all_inclusive, color: const Color(0xFF665FBE), size: 28),
                      const SizedBox(width: 10),
                      Text(isTimerEnabled ? "$selectedTime min" : "No Limit",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),

            // --- START BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                 
                  Navigator.pushNamed(context, 'identification'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7F32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 3,
                ),
                child: const Text("Start Quiz!",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}