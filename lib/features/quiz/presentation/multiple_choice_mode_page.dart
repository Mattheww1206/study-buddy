import 'package:flutter/material.dart';

class MultipleChoiceModePage extends StatefulWidget {
  const MultipleChoiceModePage({super.key});

  @override
  State<MultipleChoiceModePage> createState() => _MultipleChoiceModePageState();
}

class _MultipleChoiceModePageState extends State<MultipleChoiceModePage> {
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
        // BACK BUTTON FUNCTIONALITY
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 38), // PINALAKI ANG ICON
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Quiz Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20), // PINALAKI ANG TEXT
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18), // PINALAKI ANG PADDING NG BODY
        child: Column(
          children: [
            // --- SELECTED MODE SECTION ---
            Container(
              padding: const EdgeInsets.all(22), // PINALAKI ANG PADDING
              decoration: BoxDecoration(
                color: const Color(0xFF665FBE),
                borderRadius: BorderRadius.circular(28), // MAS ROUNDED
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SELECTED MODE",
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12), // PINALAKI ANG PADDING
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.edit_document, color: Colors.white, size: 28), // PINALAKI ANG ICON
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Multiple Choice",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)), // PINALAKI ANG TEXT
                            Text("Pick 1 correct answer from 4 options",
                                style: TextStyle(color: Colors.white70, fontSize: 14)), // PINALAKI ANG TEXT
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18), // SAKTONG GAP

            // --- NUMBER OF QUESTIONS SECTION ---
            Container(
              padding: const EdgeInsets.all(20), // PINALAKI ANG PADDING
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28), // MAS ROUNDED
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: Color(0xFF665FBE), size: 26), // PINALAKI ANG ICON
                      SizedBox(width: 10),
                      Text("Number of Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // PINALAKI ANG TEXT
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _questionsController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        numberOfQuestions = int.tryParse(val) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15), // PINALAKI ANG PADDING
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 1.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF665FBE), width: 2.2),
                      ),
                    ),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF665FBE)), // PINALAKI ANG TEXT
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // --- QUIZ TIMER SECTION ---
            Container(
              padding: const EdgeInsets.all(20), // PINALAKI ANG PADDING
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28), // MAS ROUNDED
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Color(0xFF2D2D5E), size: 26), // PINALAKI ANG ICON
                          SizedBox(width: 10),
                          Text("Quiz Timer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // PINALAKI ANG TEXT
                        ],
                      ),
                      Switch(
                        value: isTimerEnabled,
                        onChanged: (val) => setState(() => isTimerEnabled = val),
                        activeColor: const Color(0xFF665FBE),
                        materialTapTargetSize: MaterialTapTargetSize.padded, // MAS MADALING PINDUTIN
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isTimerEnabled)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [10, 15, 20, 25, 30].map((time) {
                          bool isSelected = selectedTime == time;
                          return GestureDetector(
                            onTap: () => setState(() => selectedTime = time),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), // PINALAKI ANG CHIPS
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF665FBE) : const Color(0xFFFAEEFF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                "${time}m",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF665FBE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18, // PINALAKI ANG TEXT NG CHIPS
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
            const SizedBox(height: 18),

            // --- QUIZ SUMMARY SECTION ---
            Container(
              padding: const EdgeInsets.all(22), // PINALAKI ANG PADDING
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("QUIZ SUMMARY",
                      style: TextStyle(color: Color(0xFF665FBE), fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.edit_document, color: Color(0xFFFF7F32), size: 30), // PINALAKI ANG ICON
                      const SizedBox(width: 12),
                      const Text("Multiple Choice", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // PINALAKI ANG TEXT
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.format_list_numbered, color: Color(0xFF665FBE), size: 30), // PINALAKI ANG ICON
                      const SizedBox(width: 12),
                      Text("$numberOfQuestions Questions", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // PINALAKI ANG TEXT
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(isTimerEnabled ? Icons.timer : Icons.all_inclusive, color: const Color(0xFF665FBE), size: 30), // PINALAKI ANG ICON
                      const SizedBox(width: 12),
                      Text(isTimerEnabled ? "$selectedTime min" : "No Limit",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // PINALAKI ANG TEXT
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25), // SAKTONG GAP BAGO ANG BUTTON

            // --- START BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 62, // PINALAKI ANG HEIGHT NG BUTTON
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'multiple_choice');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7F32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 5,
                ),
                child: const Text("Start Quiz!",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), // PINALAKI ANG TEXT
              ),
            ),
            const SizedBox(height: 10), // KONTING SPACE SA BABA PARA HINDI SAGAD
          ],
        ),
      ),
    );
  }
}