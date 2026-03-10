import 'package:flutter/material.dart';

class TrueFalsePage extends StatefulWidget {
  const TrueFalsePage({super.key});

  @override
  State<TrueFalsePage> createState() => _TrueFalsePageState();
}

class _TrueFalsePageState extends State<TrueFalsePage> {
  int currentQuestion = 1;
  int totalQuestions = 11;
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    double progressValue = currentQuestion / totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'State Management',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Question info and Timer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question $currentQuestion/$totalQuestions',
                        style: const TextStyle(
                          color: Color(0xFF665FBE), 
                          fontSize: 22, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${(progressValue * 100).toInt()}% Completed',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 18, color: Color(0xFF6A5AE0)),
                        SizedBox(width: 5),
                        Text('19:59', style: TextStyle(color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7F32)),
                  minHeight: 10,
                ),
              ),
            ),

            // Question Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 240,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'What method is used to navigate to new screens?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF665FBE),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // --- CHOICES SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // TRUE BUTTON
                  GestureDetector(
                    onTap: () => setState(() => selectedAnswer = 'TRUE'),
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: selectedAnswer == 'TRUE' ? const Color(0xFF6A5AE0) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6A5AE0), width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          'TRUE',
                          style: TextStyle(
                            color: selectedAnswer == 'TRUE' ? Colors.white : const Color(0xFF6A5AE0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // FALSE BUTTON
                  GestureDetector(
                    onTap: () => setState(() => selectedAnswer = 'FALSE'),
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: selectedAnswer == 'FALSE' ? const Color(0xFF6A5AE0) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6A5AE0), width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          'FALSE',
                          style: TextStyle(
                            color: selectedAnswer == 'FALSE' ? Colors.white : const Color(0xFF6A5AE0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),

            // --- NEXT/SUBMIT BUTTON ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  // Tinanggal ang validation. Pwedeng pindutin kahit walang sagot.
                  if (currentQuestion < totalQuestions) {
                    setState(() {
                      currentQuestion++;
                      selectedAnswer = null; 
                    });
                  } else {
                    // Pupunta na sa Result Screen
                    Navigator.pushNamed(context, 'tf_result');
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7F32), // Laging orange na ang kulay
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7F32).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentQuestion < totalQuestions ? 'Next Question' : 'Submit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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