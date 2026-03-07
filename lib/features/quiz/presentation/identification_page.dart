import 'package:flutter/material.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  // Controller para makuha ang text na itatype ng user
  final TextEditingController _answerController = TextEditingController();

  // --- DINAGDAG NA VARIABLES PARA SA LOGIC ---
  int currentIndex = 0; 
  final int totalQuestions = 10; 

  // Color Palette
  final Color dominantColor = const Color(0xFF665FBE);
  final Color secondaryColor = const Color(0xFFFAEEFF);
  final Color accentColor = const Color(0xFFFF6D00);

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pag-calculate ng progress percentage
    double progressValue = (currentIndex + 1) / totalQuestions;
    int progressPercent = (progressValue * 100).toInt();

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: dominantColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Biology Quiz", 
          style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- STATUS SECTION (Dynamic na ito) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Question ${currentIndex + 1}/$totalQuestions",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: dominantColor,
                                    fontSize: 22)),
                            Text("$progressPercent% Completed",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 16)),
                          ],
                        ),
                        // Timer Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: dominantColor.withOpacity(0.2), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined, color: dominantColor, size: 18),
                              const SizedBox(width: 6),
                              Text("18:42",
                                  style: TextStyle(
                                      color: dominantColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue, // Dynamic value
                        backgroundColor: Colors.white,
                        color: accentColor,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- QUESTION CARD ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: Text(
                  "What type of cell division produces 4 genetically unique daughter cells?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: dominantColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 40),

              // --- IDENTIFICATION INPUT FIELD ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Answer:",
                      style: TextStyle(
                          color: dominantColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _answerController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Type your answer here...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: dominantColor.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: dominantColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- DYNAMIC BUTTON (NEXT O SUBMIT) ---
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (currentIndex < totalQuestions - 1) {
                        // HINDI PA HULI: Next Question Logic
                        setState(() {
                          currentIndex++;
                          _answerController.clear(); // Nililinis ang input field para sa next
                        });
                        print("Moving to next question. Index: $currentIndex");
                      } else {
                        // HULI NA: Submit Logic
                        String userAnswer = _answerController.text;
                        print("Final Answer Submitted: $userAnswer");
                        Navigator.pushNamed(context, 'iden_result');
                      }
                    },
                    child: Text(
                      currentIndex < totalQuestions - 1 ? "Next Question" : "Submit Answer",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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